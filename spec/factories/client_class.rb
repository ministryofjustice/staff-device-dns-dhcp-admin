FactoryBot.define do
  factory :client_class do
    sequence(:name) { |n| "My client class #{n}" }
    sequence(:client_id) { |n| "client-class-id-#{n}" }
    domain_name_servers { "12.0.4.1,12.0.4.5" }
    domain_name { "www.example.com" }
  end
end
