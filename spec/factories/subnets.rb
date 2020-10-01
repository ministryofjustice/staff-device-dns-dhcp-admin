FactoryBot.define do
  factory :subnet do
    sequence(:cidr_block) { |n| "10.#{n}.4.0/24" }
    start_address { "10.0.4.1" }
    end_address { "10.0.4.255" }

    site
  end
end
