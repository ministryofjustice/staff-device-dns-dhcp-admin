class Option < ApplicationRecord
  belongs_to :subnet

  validates :subnet, presence: true
  INVALID_IPV4_LIST_MESSAGE = "contains an invalid IPv4 address or is not separated using commas"
  validates :routers, ipv4_list: {message: INVALID_IPV4_LIST_MESSAGE}
  validates :domain_name_servers, ipv4_list: {message: INVALID_IPV4_LIST_MESSAGE}
  validates :valid_lifetime, numericality: {greater_than_or_equal_to: 0, only_integer: true},
                             allow_nil: true

  validate :at_least_one_option

  before_validation :strip_whitespace

  audited

  def routers
    return [] unless self[:routers]
    self[:routers].split(",")
  end

  def domain_name_servers
    return [] unless self[:domain_name_servers]
    self[:domain_name_servers].split(",")
  end

  private

  def at_least_one_option
    return if routers.any? || domain_name_servers.any? || domain_name.present?
    errors.add(:base, "At least one option must be filled out")
  end

  def strip_whitespace
    self[:routers] = self[:routers]&.strip&.delete(" ")
    self[:domain_name_servers] = self[:domain_name_servers]&.strip&.delete(" ")
  end
end
