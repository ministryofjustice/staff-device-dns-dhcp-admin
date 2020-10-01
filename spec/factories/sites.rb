FactoryBot.define do
  factory :site do
    sequence(:fits_id) { |n| "FITS#{n}" }
    sequence(:name) { |n| "Site #{n}" }
  end
end
