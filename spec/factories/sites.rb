FactoryBot.define do
  factory :site do
    sequence(:fits_id) { |n| "FITS#{n}" }
    sequence(:name) { |n| "Site #{n}" }
    uuid { SecureRandom.uuid }

    trait :with_subnet do
      after :create do |site|
        shared_network = create(:shared_network, site: site)
        create(:subnet, shared_network: shared_network)
      end
    end
  end
end
