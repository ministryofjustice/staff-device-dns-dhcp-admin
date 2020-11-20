FactoryBot.define do
  factory :subnet do
    transient do
      index { 0 }
    end

    cidr_block { "10.#{index}.4.0/24" }
    start_address { "10.#{index}.4.1" }
    end_address { "10.#{index}.4.255" }

    site

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
