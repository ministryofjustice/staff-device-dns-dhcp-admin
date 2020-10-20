FactoryBot.define do
  factory :reservation do
    subnet
    hw_address { "01:bb:cc:dd:ee:ff" }
    ip_address { "192.0.2.1" }
    hostname { "test.example.com" }
    description { "Test reservation" }
  end
end
