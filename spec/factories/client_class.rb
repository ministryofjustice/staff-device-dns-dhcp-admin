FactoryBot.define do
  factory :client_class do
    name { "usr1_device" }
    client_id { "A20YYQ" }
    domain_name_servers { "12.0.4.1,12.0.4.5" }
    domain_name { "www.example.com" }
  end
end
