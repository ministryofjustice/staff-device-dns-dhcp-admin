class Site < ApplicationRecord
  has_many :shared_networks, dependent: :destroy
  has_many :subnets, through: :shared_networks

  validates :fits_id, presence: true, uniqueness: {case_sensitive: false}
  validates :name, presence: true, uniqueness: {case_sensitive: false}

  audited
end
