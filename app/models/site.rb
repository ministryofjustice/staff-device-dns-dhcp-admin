class Site < ApplicationRecord
  has_many :subnets

  validates :fits_id, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
