FactoryBot.define do
  factory :global_option do
    routers { "10.0.4.0,10.0.4.2" }
    domain_name_servers { "12.0.4.1,12.0.4.5" }
    domain_name { "www.example.com" }
  end
end
