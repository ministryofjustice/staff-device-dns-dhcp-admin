FactoryBot.define do
  factory :subnet do
    cidr_block { "10.0.4.0/24" }
    start_address { "10.0.4.1" }
    end_address { "10.0.4.255" }
  end
end
