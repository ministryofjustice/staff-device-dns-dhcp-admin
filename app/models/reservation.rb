class Reservation < ApplicationRecord
  before_validation :strip_whitespace
  MAC_ADDRESS_REGEX = /\A([0-9a-fA-F][0-9a-fA-F]:){5}([0-9a-fA-F][0-9a-fA-F])\z/

  belongs_to :subnet

  validates :ip_address, presence: true
  validates :hostname, domain_name: true
  validates :hw_address, format: {with: MAC_ADDRESS_REGEX}, presence: true

  validate :ip_address_is_a_valid_ipv4_address
  validate :ip_address_is_within_the_subnet

  delegate :ip_addr, :start_address_ip_addr, :end_address_ip_addr, to: :subnet, prefix: true

  def ip_addr
    IPAddr.new(ip_address)
  end

  private

  def ip_address_is_a_valid_ipv4_address
    return if ip_address.blank?

    unless IPAddress.valid_ipv4?(ip_address)
      errors.add(:ip_address, "is not a valid IPv4 address")
    end
  end

  def ip_address_is_within_the_subnet
    return if ip_address.blank?
    return unless IPAddress.valid_ipv4?(ip_address)

    if !subnet_ip_addr.include?(ip_addr) ||
        (ip_addr < subnet_start_address_ip_addr || ip_addr > subnet_end_address_ip_addr)
      errors.add(:ip_address, "is not within the subnet range")
    end
  end

  def strip_whitespace
    puts self.inspect
    self.hw_address = self.hw_address.strip unless self.hw_address.nil?
    self.ip_address = self.ip_address.strip unless self.ip_address.nil?
    self.hostname = self.hostname.strip unless self.hostname.nil?
    puts "-------------------------------------------"
    puts self.inspect
  end
end
