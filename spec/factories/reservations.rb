FactoryBot.define do
  factory :reservation do
    subnet factory: :subnet, cidr_block: "192.0.2.1/24"
    hw_address { "01:bb:cc:dd:ee:ff" }
    ip_address { "192.0.2.1" }
    hostname { "test.example.com" }
    description { "Test reservation" }
  end
end
