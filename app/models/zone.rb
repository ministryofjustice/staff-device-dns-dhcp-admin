class Zone < ApplicationRecord
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :forwarders,
    presence: {message: "must contain at least one IPv4 address separated using commas"},
    ipv4_list: {message: "contains an invalid IPv4 address or is not separated using commas"}

  def forwarders
    return [] unless self[:forwarders]
    self[:forwarders].split(",")
  end
end
