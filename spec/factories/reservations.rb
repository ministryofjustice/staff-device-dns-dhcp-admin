FactoryBot.define do
  factory :reservation do
    subnet factory: :subnet, start_address: "192.0.2.1", end_address: "192.0.2.255", cidr_block: "192.0.2.1/24"
    hw_address { "01:bb:cc:dd:ee:ff" }
    ip_address { subnet.start_address }
    hostname { "test.example.com" }
    description { "Test reservation" }

    trait :with_option do
      after(:create) do |reservation|
        create(:reservation_option, reservation: reservation)
      end
    end
  end
end
