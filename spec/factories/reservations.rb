FactoryBot.define do
  factory :reservation do
    transient do
      sequence(:index) { |n| n }
    end

    subnet
    hw_address { "#{index + 10}:bb:cc:dd:ee:ff" }
    ip_address { 
      octets = subnet.start_address.split('.')
      last_octet = octets.last.to_i
      octets[3] = (last_octet + index).to_s
      octets.join('.')
    }
    hostname { "test#{index}.example.com" }
    description { "Test reservation" }

    trait :with_option do
      after(:create) do |reservation|
        create(:reservation_option, reservation: reservation)
      end
    end
  end
end
