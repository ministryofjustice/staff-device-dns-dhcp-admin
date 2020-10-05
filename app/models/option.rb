class Option < ApplicationRecord
  belongs_to :subnet

  validates :routers, presence: {message: "must contain at least one IPv4 address"}, ipv4_list: true
  validates :domain_name_servers, presence: {message: "must contain at least one IPv4 address"}, ipv4_list: true
  validates :domain_name, presence: true

  def routers
    return [] unless self[:routers]
    self[:routers].split(",")
  end

  def routers=(val)
    if val.respond_to?(:join)
      self[:routers] = val.join(",")
    else
      self[:routers] = val
    end
  end

  def domain_name_servers
    return [] unless self[:domain_name_servers]
    self[:domain_name_servers].split(",")
  end

  def domain_name_servers=(val)
    if val.respond_to?(:join)
      self[:domain_name_servers] = val.join(",")
    else
      self[:domain_name_servers] = val
    end
  end
end
