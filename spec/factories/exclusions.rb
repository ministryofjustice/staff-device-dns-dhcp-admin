FactoryBot.define do
  factory :exclusion do
    subnet
    start_address { subnet.start_address.gsub(/([1-9]{1,3})$/, "50") }
    end_address { subnet.start_address.gsub(/([1-9]{1,3})$/, "100") }
  end
end
