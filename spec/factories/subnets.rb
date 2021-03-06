FactoryBot.define do
  factory :subnet do
    transient do
      sequence(:index) { |n| n }
    end

    cidr_block { "10.#{index}.4.0/24" }
    start_address { "10.#{index}.4.1" }
    end_address { "10.#{index}.4.255" }
    routers { "10.#{index}.4.0,10.#{index}.4.2" }

    shared_network

    trait :with_reservation do
      after :create do |subnet|
        create(:reservation, subnet: subnet)
      end
    end

    trait :with_option do
      after :create do |subnet|
        create(:option, subnet: subnet)
      end
    end
  end
end
