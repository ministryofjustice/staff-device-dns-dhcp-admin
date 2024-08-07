class GlobalOption < ApplicationRecord
  VALID_LIFETIME_UNIT_OPTIONS = ["Seconds", "Minutes", "Hours", "Days"]
  validates :domain_name_servers,
    presence: {message: "must contain at least one IPv4 address separated using commas"},
    ipv4_list: {message: "contains an invalid IPv4 address or is not separated using commas"}
  validates :domain_name, presence: true, domain_name: true
  validates :valid_lifetime,
    numericality: {greater_than_or_equal_to: 0, only_integer: true},
    allow_nil: true
  validates :valid_lifetime_unit,
    presence: {if: :valid_lifetime?},
    inclusion: {in: VALID_LIFETIME_UNIT_OPTIONS, message: "%{value} is not valid"}

  validate :only_one_record

  before_validation :strip_whitespace

  audited

  def domain_name_servers
    return [] unless self[:domain_name_servers]
    self[:domain_name_servers].split(",")
  end

  private

  def only_one_record
    if GlobalOption.where.not(id: id).exists?
      errors.add(:base, "A global option already exists")
    end
  end

  def strip_whitespace
    self[:domain_name_servers] = self[:domain_name_servers]&.strip&.delete(" ")
  end
end
