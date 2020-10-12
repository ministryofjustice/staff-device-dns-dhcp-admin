FactoryBot.define do
  factory :zone do
    name { "example.com" }
    forwarders { "127.0.0.5,127.0.0.8" }
    purpose { "My example app forwarding" }
  end
end
