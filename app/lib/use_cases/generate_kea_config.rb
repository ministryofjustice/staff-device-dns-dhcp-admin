# stub response until we can generate real configurations

module UseCases
  class GenerateKeaConfig
    def execute
      {
        "Dhcp4":{
          "interfaces-config":{
            "interfaces":[
              "<INTERFACE>"
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
                  "pool":"192.0.2.10 - 192.0.2.200"
                }
              ],
              "subnet":"192.0.2.0/24",
              "interface":"<INTERFACE>",
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
              "severity":"INFO"
            }
          ]
        }
      }.to_json
    end
  end
end
