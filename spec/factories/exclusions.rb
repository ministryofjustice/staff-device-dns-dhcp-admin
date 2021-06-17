FactoryBot.define do
  factory :exclusion do
    subnet
    start_address { "10.0.4.50" }
    end_address { "10.0.4.100" }
  end
end
