FactoryBot.define do
  factory :exclusion do
    subnet
    start_address { "192.168.1.10" }
    end_address { "192.168.1.20" }
  end
end
