class Option < ApplicationRecord
  belongs_to :subnet

  validates :routers,
    presence: {message: "must contain at least one IPv4 address separated using commas"},
    ipv4_list: {message: "contains an invalid IPv4 address or is not separated using commas"}
  validates :domain_name_servers,
    presence: {message: "must contain at least one IPv4 address separated using commas"},
    ipv4_list: {message: "contains an invalid IPv4 address or is not separated using commas"}
  validates :domain_name, presence: true

  def routers
    return [] unless self[:routers]
    self[:routers].split(",")
  end

  def routers=(val)
    self[:routers] = if val.respond_to?(:join)
      val.join(",")
    else
      val
    end
  end

  def domain_name_servers
    return [] unless self[:domain_name_servers]
    self[:domain_name_servers].split(",")
  end

  def domain_name_servers=(val)
    self[:domain_name_servers] = if val.respond_to?(:join)
      val.join(",")
    else
      val
    end
  end
end
