FactoryBot.define do
  factory :reservation_option do
    domain_name { "example.test.com" }
    routers { "10.0.0.1,10.0.0.100" }
    reservation
  end
end
