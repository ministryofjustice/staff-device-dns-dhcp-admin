module UseCases
  class GenerateKeaConfig
    DEFAULT_VALID_LIFETIME_SECONDS = 4000

    def initialize(subnets: [], global_option: nil, client_classes: [])
      @subnets = subnets
      @global_option = global_option
      @client_classes = client_classes
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
      }.merge(subnet_valid_lifetime_config(subnet.option))
        .merge(reservations_config(subnet.reservations))
        .merge({"require-client-classes": [subnet.client_class_name]})
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
          .merge(UseCases::KeaConfig::GenerateOptionDataConfig.new.call(reservation.reservation_option))
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
      return {} if @client_classes.blank? && subnet_option_client_classes.none?

      result = {
        "client-classes": []
      }

      result[:"client-classes"] += @client_classes.map { |client_class|
        {
          name: client_class.name,
          test: "option[77].hex == '#{client_class.client_id}'"
        }.merge(UseCases::KeaConfig::GenerateOptionDataConfig.new.call(client_class))
      }

      result[:"client-classes"] += subnet_option_client_classes

      result
    end

    def subnet_option_client_classes
      @subnet_option_client_classes ||= begin
        option_client_classes = @subnets.filter_map { |subnet|

          options_config = UseCases::KeaConfig::GenerateOptionDataConfig.new.call(subnet)
          {
            name: subnet.client_class_name,
            test: "member('ALL')",
            "only-if-required": true
          }.merge(options_config)
        }

        option_client_classes
      end
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
              severity: "INFO",
              debuglevel: 0
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
                    "heartbeat-delay": 5000,
                    "max-response-delay": 5000,
                    "max-ack-delay": 5000,
                    "max-unacked-clients": 0,
                    "peers": [
                      {
                        "name": "primary",
                        "url": "http://<PRIMARY_IP>:8000",
                        "role": "primary",
                        "auto-failover": true
                      },
                      {
                        "name": "standby",
                        "url": "http://<STANDBY_IP>:8000",
                        "role": "standby",
                        "auto-failover": true
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
        }.merge(UseCases::KeaConfig::GenerateOptionDataConfig.new.call(@global_option))
          .merge(valid_lifetime_config)
          .merge(client_class_config)
      }
    end
  end
end
