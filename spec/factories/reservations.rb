FactoryBot.define do
  factory :reservation do
    subnet { nil }
    hw_address { "MyString" }
    ip_address { "MyString" }
    hostname { "MyString" }
    description { "MyString" }
  end
end
