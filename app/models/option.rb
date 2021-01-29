class Option < ApplicationRecord
  INVALID_IPV4_LIST_MESSAGE = "contains an invalid IPv4 address or is not separated using commas"
  VALID_LIFETIME_UNIT_OPTIONS = ["Seconds", "Minutes", "Hours", "Days"]

  belongs_to :subnet

  validates :subnet, presence: true
  validates :domain_name_servers, ipv4_list: {message: INVALID_IPV4_LIST_MESSAGE}
  validates :valid_lifetime,
    numericality: {greater_than_or_equal_to: 0, only_integer: true},
    allow_nil: true
  validates :domain_name, domain_name: true
  validates :valid_lifetime_unit,
    presence: {if: :valid_lifetime?},
    inclusion: {in: VALID_LIFETIME_UNIT_OPTIONS, message: "%{value} is not valid"}

  validate :at_least_one_option

  before_validation :strip_whitespace

  audited

  def domain_name_servers
    return [] unless self[:domain_name_servers]
    self[:domain_name_servers].split(",")
  end

  private

  def at_least_one_option
    return if domain_name_servers.any? || domain_name.present? || valid_lifetime.present?
    errors.add(:base, "At least one option must be filled out")
  end

  def strip_whitespace
    self[:domain_name_servers] = self[:domain_name_servers]&.strip&.delete(" ")
  end
end
