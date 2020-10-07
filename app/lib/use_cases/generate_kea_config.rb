module UseCases
  class GenerateKeaConfig
    def initialize(subnets: [])
      @subnets = subnets
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
    end

    def options_config(option)
      return {} unless option.present?

      result = {
        "option-data": []
      }

      result[:"option-data"] << {
        "name": "domain-name-servers",
        "data": option.domain_name_servers.join(", ")
      } if option.domain_name_servers.any?

      result[:"option-data"] << {
        "name": "routers",
        "data": option.routers.join(", ")
      } if option.routers.any?

      result[:"option-data"] << {
        "name": "domain-name",
        "data": option.domain_name
      } if option.domain_name.present?

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
          "valid-lifetime": 4000,
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
        }
      }
    end
  end
end
