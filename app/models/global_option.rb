class GlobalOption < ApplicationRecord
  validates :routers,
    presence: {message: "must contain at least one IPv4 address separated using commas"},
    ipv4_list: {message: "contains an invalid IPv4 address or is not separated using commas"}
  validates :domain_name_servers,
    presence: {message: "must contain at least one IPv4 address separated using commas"},
    ipv4_list: {message: "contains an invalid IPv4 address or is not separated using commas"}
  validates :domain_name, presence: true, domain_name: true
  validates :valid_lifetime, numericality: {greater_than_or_equal_to: 0, only_integer: true},
                             allow_nil: true

  validate :only_one_record

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

  def only_one_record
    if GlobalOption.where.not(id: id).exists?
      errors.add(:base, "A global option already exists")
    end
  end

  def strip_whitespace
    self[:routers] = self[:routers]&.strip&.delete(" ")
    self[:domain_name_servers] = self[:domain_name_servers]&.strip&.delete(" ")
  end
end
