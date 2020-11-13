class ClientClass < ApplicationRecord
  CLIENT_ID_REGEX = /\A([0-9a-zA-Z_\-]+)\z/

  validates :name, presence: true
  validates :client_id,
    format: {with: CLIENT_ID_REGEX, message: "must contain only letters, numbers, underscores and dashes"},
    presence: true
  validates :domain_name_servers,
    presence: {message: "must contain at least one IPv4 address separated using commas"},
    ipv4_list: {message: "contains an invalid IPv4 address or is not separated using commas"}
  validates :domain_name, presence: true, domain_name: true

  validate :only_one_record

  before_validation :strip_whitespace

  audited

  def domain_name_servers
    return [] unless self[:domain_name_servers]
    self[:domain_name_servers].split(",")
  end

  private

  def only_one_record
    if ClientClass.where.not(id: id).exists?
      errors.add(:base, "A client class already exists")
    end
  end

  def strip_whitespace
    self[:domain_name_servers] = self[:domain_name_servers]&.strip&.delete(" ")
  end
end
