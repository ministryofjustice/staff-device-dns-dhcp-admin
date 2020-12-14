module UseCases
  class GenerateKeaConfig
    DEFAULT_VALID_LIFETIME_SECONDS = 4000

    def initialize(subnets: [], global_option: nil, client_class: nil)
      @subnets = subnets
      @global_option = global_option
      @client_class = client_class
    end

    def call
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
        }.merge(reservation_description(reservation))
          .merge(reservation_option_config(reservation.reservation_option))
      }

      result
    end

    def reservation_description(reservation)
      return {} if reservation.description.blank?
      {
        "user-context": {
          "description": reservation.description
        }
      }
    end

    def reservation_option_config(reservation_option)
      return {} unless reservation_option.present?

      result = {
        "option-data": []
      }

      if reservation_option.routers.any?
        result[:"option-data"] << {
          "name": "routers",
          "data": reservation_option.routers.join(", ")
        }
      end

      if reservation_option.domain_name.present?
        result[:"option-data"] << {
          "name": "domain-name",
          "data": reservation_option.domain_name
        }
      end

      result
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

    def client_class_config
      return {} if @client_class.blank?

      {
        "client-classes": [
          {
            name: @client_class.name,
            test: "option[77].hex == '#{@client_class.client_id}'",
            "option-data": [
              {name: "domain-name", data: @client_class.domain_name},
              {name: "domain-name-servers", data: @client_class.domain_name_servers.join(", ")}
            ]
          }
        ]
      }
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
          "control-socket": {
            "socket-type": "unix",
            "socket-name": "/tmp/dhcp4-socket"
          },
          subnet4: [
            {
              pools: [
                {
                  pool: "127.0.0.1 - 127.0.0.254"
                }
              ],
              subnet: "127.0.0.1/24",
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
              severity: "DEBUG",
              debuglevel: 99
            }
          ],
          "hooks-libraries": [
            {
              "library": "/usr/lib/kea/hooks/libdhcp_lease_cmds.so"
            },
            {
              "library": "/usr/lib/kea/hooks/libdhcp_stat_cmds.so"
            },
            {
              "library": "/usr/lib/kea/hooks/libdhcp_ha.so",
              "parameters": {
                "high-availability": [
                {
                  "this-server-name": "<SERVER_NAME>",
                  "mode": "hot-standby",
                  "heartbeat-delay": 10000,
                  "max-response-delay": 10000,
                  "max-ack-delay": 5000,
                  "max-unacked-clients": 5,
                  "peers": [
                    {
                      "name": "primary",
                      "url": "<PRIMARY_IP>",
                      "role": "primary"
                    },
                    {
                      "name": "standby",
                      "url": "<STANDBY_IP>",
                      "role": "standby"
                    }
                  ]
                }
              ]
            }
          }
          ],
          "multi-threading": {
            "enable-multi-threading": true,
            "thread-pool-size": 12,
            "packet-queue-size": 792
          }
        }.merge(global_options_config).merge(valid_lifetime_config).merge(client_class_config)
      }
    end
  end
end
