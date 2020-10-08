class Option < ApplicationRecord
  belongs_to :subnet

  validates :subnet, presence: true
  INVALID_IPV4_LIST_MESSAGE = "contains an invalid IPv4 address or is not separated using commas"
  validates :routers, ipv4_list: {message: INVALID_IPV4_LIST_MESSAGE}
  validates :domain_name_servers, ipv4_list: {message: INVALID_IPV4_LIST_MESSAGE}

  validate :at_least_one_option

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

  private

  def at_least_one_option
    return if routers.any? || domain_name_servers.any? || domain_name.present?
    errors.add(:base, "At least one option must be filled out")
  end
end
