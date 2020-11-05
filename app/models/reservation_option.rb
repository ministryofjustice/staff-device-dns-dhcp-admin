class ReservationOption < ApplicationRecord
  belongs_to :reservation

  INVALID_IPV4_LIST_MESSAGE = "contains an invalid IPv4 address or is not separated using commas"
  validates :reservation, presence: true
  validates :routers, ipv4_list: {message: INVALID_IPV4_LIST_MESSAGE}
  validates :domain_name, domain_name: true

  validates_format_of :domain_name, :with => /\A(http|https):\/\/|[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(\/.*)?\z/ix, message: "contains an invalid domain name", allow_nil: true

  validate :at_least_one_option

  audited

  def routers
    return [] unless self[:routers]
    self[:routers].split(",")
  end

  private

  def at_least_one_option
    return if routers.any? || domain_name.present?
    errors.add(:base, "At least one option must be filled out")
  end
end
