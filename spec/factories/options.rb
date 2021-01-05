FactoryBot.define do
  factory :option do
    subnet
    domain_name_servers { "12.0.4.1,12.0.4.5" }
    domain_name { "www.examgitple.com" }
  end
end
