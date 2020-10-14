class GlobalOption < ApplicationRecord
  validates :routers,
    presence: {message: "must contain at least one IPv4 address separated using commas"},
    ipv4_list: {message: "contains an invalid IPv4 address or is not separated using commas"}
  validates :domain_name_servers,
    presence: {message: "must contain at least one IPv4 address separated using commas"},
    ipv4_list: {message: "contains an invalid IPv4 address or is not separated using commas"}
  validates :domain_name, presence: true

  validate :only_one_record

  audited

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

  def only_one_record
    if GlobalOption.where.not(id: id).exists?
      errors.add(:base, "A global option already exists")
    end
  end
end
