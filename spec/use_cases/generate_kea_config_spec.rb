require "rails_helper"

describe UseCases::GenerateKeaConfig do
  describe "#execute" do
    it "returns a default subnet used for smoke testing" do
      config = UseCases::GenerateKeaConfig.new.execute

      expect(config.dig(:Dhcp4, :subnet4)).to match_array([
        {
          pools: [
            {
              pool: "172.0.0.1 - 172.0.2.0"
            }
          ],
          subnet: "127.0.0.1/0",
          id: 1
        }
      ])
    end

    it "appends subnets to the subnet4 list" do
      site = build_stubbed(:site, fits_id: "FITSID01", name: "SITENAME01")
      subnet1 = build_stubbed(:subnet, cidr_block: "10.0.1.0/24", start_address: "10.0.1.1", end_address: "10.0.1.255", site: site)
      subnet2 = build_stubbed(:subnet, cidr_block: "10.0.2.0/24", start_address: "10.0.2.1", end_address: "10.0.2.255", site: site)

      config = UseCases::GenerateKeaConfig.new(subnets: [subnet1, subnet2]).execute

      expect(config.dig(:Dhcp4, :subnet4)).to match_array([
        {
          pools: [
            {
              pool: "172.0.0.1 - 172.0.2.0"
            }
          ],
          subnet: "127.0.0.1/0",
          id: 1
        },
        {
          pools: [
            {
              pool: "10.0.1.1 - 10.0.1.255"
            }
          ],
          subnet: "10.0.1.0/24",
          id: subnet1.kea_id,
          "user-context": {
            "site-id": subnet1.site.fits_id,
            "site-name": subnet1.site.name
          }
        },
        {
          pools: [
            {
              pool: "10.0.2.1 - 10.0.2.255"
            }
          ],
          subnet: "10.0.2.0/24",
          id: subnet2.kea_id,
          "user-context": {
            "site-id": subnet1.site.fits_id,
            "site-name": subnet1.site.name
          }
        }
      ])
    end

    it "returns a kea config with the correct keys" do
      config = UseCases::GenerateKeaConfig.new.execute
      expect(config).to have_key :Dhcp4
      expect(config[:Dhcp4].keys).to match_array([
        :"host-reservation-identifiers", :"hosts-database", :"interfaces-config",
        :"lease-database", :"valid-lifetime", :loggers, :subnet4
      ])
    end

    it "offsets the id to avoid collision with the reserved smoke testing subnet" do
      subnet1 = build_stubbed(:subnet, id: 1, cidr_block: "10.0.1.0/24")
      subnet2 = build_stubbed(:subnet, id: 2, cidr_block: "10.0.2.0/24")

      config = UseCases::GenerateKeaConfig.new(subnets: [subnet1, subnet2]).execute

      expect(config.dig(:Dhcp4, :subnet4)).to match_array([
        hash_including(subnet: "127.0.0.1/0", id: 1),
        hash_including(subnet: "10.0.1.0/24", id: 1001),
        hash_including(subnet: "10.0.2.0/24", id: 1002)
      ])
    end

    it "appends options to the subnet" do
      option = build_stubbed(:option, routers: nil, valid_lifetime: 1234)

      config = UseCases::GenerateKeaConfig.new(subnets: [option.subnet]).execute

      expect(config.dig(:Dhcp4, :subnet4)).to include(hash_including({
        "valid-lifetime": 1234,
        "option-data": [
          {
            "name": "domain-name-servers",
            "data": option.domain_name_servers.join(", ")
          },
          {
            "name": "domain-name",
            "data": option.domain_name
          }
        ]
      }))
    end

    it "includes global options in the config" do
      global_option = build_stubbed(:global_option)

      config = UseCases::GenerateKeaConfig.new(subnets: [], global_option: global_option).execute

      expect(config.dig(:Dhcp4, :"option-data")).to match_array([
        {
          "name": "domain-name-servers",
          "data": global_option.domain_name_servers.join(", ")
        },
        {
          "name": "domain-name",
          "data": global_option.domain_name
        },
        {
          "name": "routers",
          "data": global_option.routers.join(", ")
        }
      ])
    end

    it "does not set the global options if none are passed in" do
      config = UseCases::GenerateKeaConfig.new(subnets: [], global_option: nil).execute
      expect(config[:Dhcp4].keys).to_not include :"option-data"
    end

    it "sets a default valid lifetime if a global option is not passed in" do
      config = UseCases::GenerateKeaConfig.new(subnets: [], global_option: nil).execute

      expect(config.dig(:Dhcp4, :"valid-lifetime")).to eq 4000
    end

    it "sets a default valid lifetime if the global option has no valid lifetime set" do
      global_option = build_stubbed(:global_option, valid_lifetime: nil)
      config = UseCases::GenerateKeaConfig.new(subnets: [], global_option: global_option).execute

      expect(config.dig(:Dhcp4, :"valid-lifetime")).to eq 4000
    end

    it "sets the valid-lifetime using the global option valid lifetime" do
      global_option = build_stubbed(:global_option, valid_lifetime: 600)
      config = UseCases::GenerateKeaConfig.new(subnets: [], global_option: global_option).execute

      expect(config.dig(:Dhcp4, :"valid-lifetime")).to eq 600
    end

    it "does not set the valid lifetime for a subnet if the subnet option is not set" do
      subnet = build_stubbed(:subnet, option: nil)
      config = UseCases::GenerateKeaConfig.new(subnets: [subnet]).execute

      expect(config.dig(:Dhcp4, :subnet4)).to_not include(hash_including(:"valid-lifetime"))
    end

    it "does not set the valid lifetime for a subnet if the subnet option does not set a valid lifetime" do
      option = build_stubbed(:option, valid_lifetime: nil)
      config = UseCases::GenerateKeaConfig.new(subnets: [option.subnet]).execute

      expect(config.dig(:Dhcp4, :subnet4)).to_not include(hash_including(:"valid-lifetime"))
    end

    it "sets the valid-lifetime for a subnet using the subnet option" do
      option = build_stubbed(:option, valid_lifetime: 1800)
      config = UseCases::GenerateKeaConfig.new(subnets: [option.subnet]).execute

      expect(config.dig(:Dhcp4, :subnet4)).to include(hash_including("valid-lifetime": 1800))
    end

    it "appends reservation to the subnet" do
      reservation = create(:reservation)

      config = UseCases::GenerateKeaConfig.new(subnets: [reservation.subnet]).execute

      expect(config.dig(:Dhcp4, :subnet4)).to include(hash_including({
        "reservations": [
          {
            "hw-address": reservation.hw_address,
            "ip-address": reservation.ip_address,
            "hostname": reservation.hostname,
            "user-context": {
              "description": reservation.description
            }
          }
        ]
      }))
    end

    it "appends reservation option to the reservation" do
      reservation_option = create(:reservation_option)
      reservation = reservation_option.reservation

      config = UseCases::GenerateKeaConfig.new(subnets: [reservation.subnet]).execute

      expect(config.dig(:Dhcp4, :subnet4)).to include(hash_including({
        "reservations": [
          {
            "hw-address": reservation.hw_address,
            "ip-address": reservation.ip_address,
            "hostname": reservation.hostname,
            "option-data": [
              {
                "name": "routers",
                "data": reservation_option.routers.join(", ")
              },
              {
                "name": "domain-name",
                "data": reservation_option.domain_name
              }
            ],
            "user-context": {
              "description": reservation.description
            }
          }
        ]
      }))
    end

    it "appends reservation option without a domain name to the reservation" do
      reservation_option = create(:reservation_option, domain_name: nil)
      reservation = reservation_option.reservation

      config = UseCases::GenerateKeaConfig.new(subnets: [reservation.subnet]).execute

      expect(config.dig(:Dhcp4, :subnet4)).to include(hash_including({
        "reservations": [
          {
            "hw-address": reservation.hw_address,
            "ip-address": reservation.ip_address,
            "hostname": reservation.hostname,
            "option-data": [
              {
                "name": "routers",
                "data": reservation_option.routers.join(", ")
              }
            ],
            "user-context": {
              "description": reservation.description
            }
          }
        ]
      }))
    end

    it "appends reservation without description to the subnet" do
      reservation = create(:reservation, description: nil)

      config = UseCases::GenerateKeaConfig.new(subnets: [reservation.subnet]).execute

      expect(config.dig(:Dhcp4, :subnet4)).to include(hash_including({
        "reservations": [
          {
            "hw-address": reservation.hw_address,
            "ip-address": reservation.ip_address,
            "hostname": reservation.hostname
          }
        ]
      }))
    end

    it "appends multiple reservations to the subnet" do
      subnet = create(:subnet, cidr_block: "10.7.4.0/24", start_address: "10.7.4.1", end_address: "10.7.4.255")
      reservation1 = create(:reservation, subnet: subnet, ip_address: "10.7.4.2")
      reservation2 = create(:reservation, subnet: subnet, ip_address: "10.7.4.3", hostname: "reservation2.example.com", hw_address: "01:bb:cc:dd:ee:ee")

      config = UseCases::GenerateKeaConfig.new(subnets: [reservation1.subnet]).execute

      expect(config.dig(:Dhcp4, :subnet4)).to include(hash_including({
        "reservations": [
          {
            "hw-address": reservation1.hw_address,
            "ip-address": reservation1.ip_address,
            "hostname": reservation1.hostname,
            "user-context": {
              "description": reservation1.description
            }
          },
          {
            "hw-address": reservation2.hw_address,
            "ip-address": reservation2.ip_address,
            "hostname": reservation2.hostname,
            "user-context": {
              "description": reservation2.description
            }
          }
        ]
      }))
    end
  end
end
