class Site < ApplicationRecord
  validates :fits_id, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
