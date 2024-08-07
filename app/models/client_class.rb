class ClientClass < ApplicationRecord
  CLIENT_ID_REGEX = /\A([0-9a-zA-Z_\-]+)\z/

  validates :name,
    presence: true,
    uniqueness: {case_sensitive: false}
  validates :client_id,
    presence: true,
    uniqueness: {case_sensitive: false},
    format: {with: CLIENT_ID_REGEX, message: "must contain only letters, numbers, underscores and dashes"}
  validates :domain_name_servers,
    presence: {message: "must contain at least one IPv4 address separated using commas"},
    ipv4_list: {message: "contains an invalid IPv4 address or is not separated using commas"}
  validates :domain_name,
    presence: true,
    domain_name: true
  validate :name_cannot_start_with_subnet

  before_validation :strip_whitespace

  audited

  def domain_name_servers
    return [] unless self[:domain_name_servers]
    self[:domain_name_servers].split(",")
  end

  private

  def name_cannot_start_with_subnet
    return if name.blank?

    if name.start_with?(Subnet::CLIENT_CLASS_NAME_PREFIX)
      # subnet prefix is reserved for Subnet#client_class_name
      errors.add(:name, "cannot begin with the word '#{Subnet::CLIENT_CLASS_NAME_PREFIX}'")
    end
  end

  def strip_whitespace
    self[:client_id] = self[:client_id]&.strip
    self[:domain_name] = self[:domain_name]&.strip
    self[:domain_name_servers] = self[:domain_name_servers]&.strip&.delete(" ")
  end
end
