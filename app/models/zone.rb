class Zone < ApplicationRecord
  validates :name, presence: true, uniqueness: {case_sensitive: false}, domain_name: true

  validates :forwarders,
    presence: {message: "must contain at least one IPv4 address separated using commas"},
    ipv4_list: {message: "contains an invalid IPv4 address or is not separated using commas"}

  before_save { name.downcase! }

  before_validation :strip_whitespace

  audited

  def forwarders
    return [] unless self[:forwarders]
    self[:forwarders].split(",")
  end

  private

  def strip_whitespace
    self[:forwarders] = self[:forwarders]&.strip&.delete(" ")
  end
end
