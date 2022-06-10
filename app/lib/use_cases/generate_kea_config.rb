require "ipaddr"

module UseCases
  class GenerateKeaConfig
    DEFAULT_VALID_LIFETIME_SECONDS = 4000
    SECONDS_IN_A_DAY = 86400
    SECONDS_IN_AN_HOUR = 3600
    SECONDS_IN_A_MINUTE = 60

    def initialize(subnets: [], global_option: nil, client_classes: [])
      @subnets = subnets
      @global_option = global_option
      @client_classes = client_classes
    end

    def call
      config = default_config

      config[:Dhcp4][:"shared-networks"] += shared_networks_config

      config
    end

    private

    def ip_string(ip)
      IPAddr.new(ip, Socket::AF_INET).to_s
    end

    def create_pools(subnet)
      if subnet.exclusions.any?
        first_exclusion_start_address = IPAddr.new(subnet.exclusions.first.start_address).to_i
        first_exclusion_end_address = IPAddr.new(subnet.exclusions.first.end_address).to_i

        if subnet.exclusions.first.start_address == subnet.start_address && subnet.exclusions.first.end_address == subnet.end_address
          return []
        end

        if subnet.exclusions.first.start_address == subnet.start_address
          return [
            {
              pool: "#{ip_string(first_exclusion_end_address + 1)} - #{subnet.end_address}"
            }
          ]
        end

        if subnet.exclusions.first.end_address == subnet.end_address
          return [
            {
              pool: "#{subnet.start_address} - #{ip_string(first_exclusion_start_address - 1)}"
            }
          ]
        end

        return [
          {
            pool: "#{subnet.start_address} - #{ip_string(first_exclusion_start_address - 1)}"
          },
          {
            pool: "#{ip_string(first_exclusion_end_address + 1)} - #{subnet.end_address}"
          }
        ]
      end

      [
        {
          pool: "#{subnet.start_address} - #{subnet.end_address}"
        }
      ]
    end

    def subnet_config(subnet)
      {
        pools: create_pools(subnet),
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

    def subnets_config(subnets)
      subnets.map do |subnet|
        subnet_config(subnet)
      end
    end

    def shared_network_config(subnets)
      shared_network = subnets.first.shared_network
      {
        name: shared_network.name,
        subnet4: subnets_config(subnets)
      }
    end

    def shared_networks_config
      @subnets.group_by(&:shared_network_id).map do |_, subnets|
        shared_network_config(subnets)
      end
    end

    def reservations_config(reservations)
      return {} unless reservations.present?

      result = {
        reservations: []
      }

      result[:reservations] += reservations.map { |reservation|
        {
          "hw-address": reservation.hw_address,
          "ip-address": reservation.ip_address,
          hostname: reservation.hostname
        }.merge(reservation_description(reservation))
          .merge(UseCases::KeaConfig::GenerateOptionDataConfig.new.call(reservation.reservation_option))
      }

      result
    end

    def reservation_description(reservation)
      return {} if reservation.description.blank?
      {
        "user-context": {
          description: reservation.description
        }
      }
    end

    def valid_lifetime_config
      return {} if @global_option.blank?
      return {} if @global_option.valid_lifetime.blank?

      {
        "valid-lifetime": calculate_valid_lifetime(@global_option.valid_lifetime, @global_option.valid_lifetime_unit)
      }
    end

    def subnet_valid_lifetime_config(option)
      return {} if option&.valid_lifetime.blank?

      {"valid-lifetime": calculate_valid_lifetime(option.valid_lifetime, option.valid_lifetime_unit)}
    end

    def calculate_valid_lifetime(valid_lifetime, unit)
      case unit
      when "Days"
        valid_lifetime * SECONDS_IN_A_DAY
      when "Hours"
        valid_lifetime * SECONDS_IN_AN_HOUR
      when "Minutes"
        valid_lifetime * SECONDS_IN_A_MINUTE
      else
        valid_lifetime
      end
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
        option_client_classes = @subnets.filter_map do |subnet|
          options_config = UseCases::KeaConfig::GenerateOptionDataConfig.new.call(subnet)
          {
            name: subnet.client_class_name,
            test: "member('ALL')",
            "only-if-required": true
          }.merge(options_config)
        end

        option_client_classes
      end
    end

    def default_config
      {
        Dhcp4: {
          "interfaces-config": {
            interfaces: ["*"],
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
          "hosts-database": {
            type: "mysql",
            name: "<DB_NAME>",
            user: "<DB_USER>",
            password: "<DB_PASS>",
            host: "<DB_HOST>",
            port: 3306
          },
          "multi-threading": {
            "enable-multi-threading": true,
            "thread-pool-size": 12,
            "packet-queue-size": 792
          },
          "valid-lifetime": DEFAULT_VALID_LIFETIME_SECONDS,
          "host-reservation-identifiers": [
            "circuit-id",
            "hw-address",
            "duid",
            "client-id"
          ],
          "control-socket": {
            "socket-type": "unix",
            "socket-name": "/tmp/dhcp4-socket"
          },
          "shared-networks": [],
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
              output_options: [
                {
                  output: "stdout"
                }
              ],
              severity: "WARN",
              debuglevel: 0
            }
          ],
          "hooks-libraries": [
            {
              library: "/usr/lib/kea/hooks/libdhcp_lease_cmds.so"
            },
            {
              library: "/usr/lib/kea/hooks/libdhcp_stat_cmds.so"
            },
            {
              library: "/usr/lib/kea/hooks/libdhcp_ha.so",
              parameters: {
                "high-availability": [
                  {
                    "this-server-name": "<SERVER_NAME>",
                    "mode": "hot-standby",
                    "heartbeat-delay": 10000,
                    "max-response-delay": 60000,
                    "max-ack-delay": 10000,
                    "max-unacked-clients": 0,
                    "multi-threading": {
                      "enable-multi-threading": true,
                      "http-dedicated-listener": true,
                      "http-listener-threads": 4,
                      "http-client-threads": 4
                    },
                    peers: [
                      {
                        name: "primary",
                        url: "http://<PRIMARY_IP>:8000",
                        role: "primary",
                        "auto-failover": true
                      },
                      {
                        name: "standby",
                        url: "http://<STANDBY_IP>:8000",
                        role: "standby",
                        "auto-failover": true
                      }
                    ]
                  }
                ]
              }
            }
          ]
        }.merge(UseCases::KeaConfig::GenerateOptionDataConfig.new.call(@global_option))
          .merge(valid_lifetime_config)
          .merge(client_class_config)
      }
    end
  end
end
