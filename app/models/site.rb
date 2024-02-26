class Site < ApplicationRecord
  has_many :shared_networks, dependent: :destroy
  has_many :subnets, through: :shared_networks
  has_many :reservations

  validates :fits_id, presence: true, uniqueness: {case_sensitive: false}
  validates :name, presence: true, uniqueness: {case_sensitive: false}

  before_save :ensure_uuid_has_a_value

  audited

  private


  scope :with_search, ->(query) {
    joins("INNER JOIN shared_networks ON shared_networks.site_id = sites.id INNER JOIN subnets ON subnets.shared_network_id = shared_networks.id")
      .where('sites.name LIKE ? OR sites.fits_id LIKE ? OR sites.id LIKE ? OR subnets.cidr_block LIKE ?', "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
      .select('sites.id,sites.fits_id, sites.name')
      .order('sites.fits_id')

  }
  def ensure_uuid_has_a_value
    self.uuid = SecureRandom.uuid unless uuid.present?
  end
end
