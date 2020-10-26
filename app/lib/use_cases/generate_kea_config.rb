module UseCases
  class GenerateKeaConfig
    DEFAULT_VALID_LIFETIME_SECONDS = 4000

    def initialize(subnets: [], global_option: nil)
      @subnets = subnets
      @global_option = global_option
    end

    def execute
      config = default_config

      config[:Dhcp4][:subnet4] += @subnets.map { |subnet| subnet_config(subnet) }

      config
    end

    private

    def subnet_config(subnet)
      {
        pools: [
          {
            pool: "#{subnet.start_address} - #{subnet.end_address}"
          }
        ],
        subnet: subnet.cidr_block,
        id: subnet.kea_id,
        "user-context": {
          "site-id": subnet.site.fits_id,
          "site-name": subnet.site.name
        }
      }.merge(options_config(subnet.option))
        .merge(subnet_valid_lifetime_config(subnet.option)).merge(reservations_config(subnet.reservations))
    end

    def options_config(option)
      return {} unless option.present?

      result = {
        "option-data": []
      }

      if option.domain_name_servers.any?
        result[:"option-data"] << {
          "name": "domain-name-servers",
          "data": option.domain_name_servers.join(", ")
        }
      end

      if option.routers.any?
        result[:"option-data"] << {
          "name": "routers",
          "data": option.routers.join(", ")
        }
      end

      if option.domain_name.present?
        result[:"option-data"] << {
          "name": "domain-name",
          "data": option.domain_name
        }
      end

      result
    end

    def global_options_config
      return {} if @global_option.blank?

      {
        "option-data": [
          {
            "name": "domain-name-servers",
            "data": @global_option.domain_name_servers.join(", ")
          }, {
            "name": "routers",
            "data": @global_option.routers.join(", ")
          }, {
            "name": "domain-name",
            "data": @global_option.domain_name
          }
        ]
      }
    end

    def valid_lifetime_config
      return {} if @global_option.blank?
      return {} if @global_option.valid_lifetime.blank?

      {
        "valid-lifetime": @global_option.valid_lifetime
      }
    end

    def subnet_valid_lifetime_config(option)
      return {} if option&.valid_lifetime.blank?

      {"valid-lifetime": option.valid_lifetime}
    end
    
    def reservations_config(reservations)
      return {} unless reservations.present?

      result = {
        "reservations": []
      }

      result[:"reservations"] += reservations.map { |reservation| {
        "hw-address": reservation.hw_address,
        "ip-address": reservation.ip_address,
        "hostname": reservation.hostname
      } }
      
      result
    end

    def reservations_config(reservations)
      return {} unless reservations.present?

      result = {
        "reservations": []
      }

      result[:reservations] += reservations.map { |reservation|
        {
          "hw-address": reservation.hw_address,
          "ip-address": reservation.ip_address,
          "hostname": reservation.hostname
        }
      }

      result
    end

    def default_config
      {
        Dhcp4: {
          "interfaces-config": {
            "interfaces": ["*"],
            "dhcp-socket-type": "udp",
            "outbound-interface": "use-routing"
          },
          "lease-database": {
            type: "mysql",
            name: "<DB_NAME>",
            user: "<DB_USER>",
            password: "<DB_PASS>",
            host: "<DB_HOST>",
            port: 3306
          },
          "valid-lifetime": DEFAULT_VALID_LIFETIME_SECONDS,
          "host-reservation-identifiers": [
            "circuit-id",
            "hw-address",
            "duid",
            "client-id"
          ],
          "hosts-database": {
            type: "mysql",
            name: "<DB_NAME>",
            user: "<DB_USER>",
            password: "<DB_PASS>",
            host: "<DB_HOST>",
            port: 3306
          },
          subnet4: [
            {
              pools: [
                {
                  pool: "172.0.0.1 - 172.0.2.0"
                }
              ],
              subnet: "127.0.0.1/0",
              id: 1 # This is the subnet used for smoke testing
            }
          ],
          loggers: [
            {
              name: "kea-dhcp4",
              "output_options": [
                {
                  output: "stdout"
                }
              ],
              severity: "DEBUG"
            }
          ]
        }.merge(global_options_config).merge(valid_lifetime_config)
      }
    end
  end
end
