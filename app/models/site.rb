class Site < ApplicationRecord
  has_many :shared_networks, dependent: :destroy
  has_many :subnets, through: :shared_networks

  validates :fits_id, presence: true, uniqueness: {case_sensitive: false}
  validates :name, presence: true, uniqueness: {case_sensitive: false}

  before_save :ensure_uuid_has_a_value

  audited

  private

  def ensure_uuid_has_a_value
    self.uuid = SecureRandom.uuid unless uuid.present?
  end
end
