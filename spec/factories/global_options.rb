FactoryBot.define do
  factory :global_option do
    domain_name_servers { "12.0.4.1,12.0.4.5" }
    domain_name { "www.example.com" }
  end
end
