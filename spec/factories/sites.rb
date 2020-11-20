FactoryBot.define do
  factory :site do
    sequence(:fits_id) { |n| "FITS#{n}" }
    sequence(:name) { |n| "Site #{n}" }

    trait :with_subnet do
      after :create do |site|
        create(:subnet, site: site)
      end
    end
  end
end
