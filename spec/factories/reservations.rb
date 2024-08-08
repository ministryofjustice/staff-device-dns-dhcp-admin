FactoryBot.define do
  factory :reservation do
    subnet
    hw_address { "aa:bb:cc:dd:ee:ff" }
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
