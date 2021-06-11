class Subnet < ApplicationRecord
  KEA_SUBNET_ID_OFFSET = 1000
  CLIENT_CLASS_NAME_PREFIX = "subnet"
  INVALID_IPV4_LIST_MESSAGE = "contains an invalid IPv4 address or is not separated using commas"

  belongs_to :site
  has_one :option, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :exclusions, dependent: :destroy

  validates :cidr_block, presence: true, uniqueness: {case_sensitive: false}
  validates :start_address, presence: true
  validates :end_address, presence: true
  validates :routers, presence: true
  validates :routers, ipv4_list: {message: INVALID_IPV4_LIST_MESSAGE}

  validate :cidr_block_is_a_valid_ipv4_subnet, :start_address_is_a_valid_ipv4_address,
    :end_address_is_a_valid_ipv4_address, :cidr_block_address_is_unique,
    :start_address_is_within_subnet_range, :end_address_is_within_subnet_range

  before_validation :strip_whitespace

  audited

  delegate :domain_name_servers,
    :domain_name,
    :valid_lifetime,
    :valid_lifetime_unit,
    to: :option,
    allow_nil: true

  def routers
    return [] unless self[:routers]
    self[:routers].split(",")
  end

  def ip_addr
    IPAddr.new(cidr_block)
  end

  def start_address_ip_addr
    IPAddr.new(start_address)
  end

  def end_address_ip_addr
    IPAddr.new(end_address)
  end

  def kea_id
    id + KEA_SUBNET_ID_OFFSET
  end

  def cidr_block=(val)
    self[:cidr_block] = val.try(:strip)
  end

  def start_address=(val)
    self[:start_address] = val.try(:strip)
  end

  def end_address=(val)
    self[:end_address] = val.try(:strip)
  end

  def client_class_name
    "#{CLIENT_CLASS_NAME_PREFIX}-#{ip_addr}-client"
  end

  private

  def cidr_block_is_a_valid_ipv4_subnet
    return if cidr_block.blank?

    unless IPAddress.valid_ipv4_subnet?(cidr_block)
      errors.add(:cidr_block, "is not a valid IPv4 subnet")
    end
  end

  def start_address_is_a_valid_ipv4_address
    return if start_address.blank?

    unless IPAddress.valid_ipv4?(start_address)
      errors.add(:start_address, "is not a valid IPv4 address")
    end
  end

  def end_address_is_a_valid_ipv4_address
    return if end_address.blank?

    unless IPAddress.valid_ipv4?(end_address)
      errors.add(:end_address, "is not a valid IPv4 address")
    end
  end

  def cidr_block_address_is_unique
    return if cidr_block.blank?
    return unless IPAddress.valid_ipv4_subnet?(cidr_block)

    subnet_address = IPAddress::IPv4.new(cidr_block).address
    if Subnet.where.not(id: id)
        .where.not(cidr_block: cidr_block)
        .where("cidr_block LIKE ?", "#{subnet_address}/%").exists?
      errors.add(:cidr_block, "matches a subnet with the same address")
    end
  end

  def start_address_is_within_subnet_range
    return if start_address.blank? || !IPAddress.valid_ipv4?(start_address)
    return if cidr_block.blank? || !IPAddress.valid_ipv4_subnet?(cidr_block)

    unless ip_addr.include?(start_address)
      errors.add(:start_address, "is not within the subnet range")
    end
  end

  def end_address_is_within_subnet_range
    return if end_address.blank? || !IPAddress.valid_ipv4?(end_address)
    return if cidr_block.blank? || !IPAddress.valid_ipv4_subnet?(cidr_block)

    unless ip_addr.include?(end_address)
      errors.add(:end_address, "is not within the subnet range")
    end
  end

  def strip_whitespace
    self[:routers] = self[:routers]&.strip&.delete(" ")
  end
end
