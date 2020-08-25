# stub response until we can generate real configurations

module UseCases
  class GenerateKeaConfig
    def execute
      '{
        "Dhcp4":{
          "interfaces-config":{
            "interfaces":[
              "*",
              "dhcp-socket-type": "udp"
            ]
          },
          "lease-database":{
            "type":"mysql",
            "name":"<DB_NAME>",
            "user":"<DB_USER>",
            "password":"<DB_PASS>",
            "host":"<DB_HOST>",
            "port":3306
          },
          "valid-lifetime":4000,
          "host-reservation-identifiers":[
            "circuit-id",
            "hw-address",
            "duid",
            "client-id"
          ],
          "hosts-database":{
            "type":"mysql",
            "name":"<DB_NAME>",
            "user":"<DB_USER>",
            "password":"<DB_PASS>",
            "host":"<DB_HOST>",
            "port":3306
          },
          "subnet4":[
            {
              "pools":[
                {
                  "pool":"0.0.0.0 - 255.255.255.255"
                }
              ],
              "subnet":"0.0.0.0/0",
              "id":1
            }
          ],
          "loggers":[
            {
              "name":"kea-dhcp4",
              "output_options":[
                {
                  "output":"stdout"
                }
              ],
              "severity":"DEBUG"
            }
          ]
        }
      }'
    end
  end
end
