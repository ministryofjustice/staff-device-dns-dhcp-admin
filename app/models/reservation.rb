class Reservation < ApplicationRecord
  MAC_ADDRESS_REGEX = /\A([0-9a-fA-F][0-9a-fA-F]:){5}([0-9a-fA-F][0-9a-fA-F])\z/

  belongs_to :subnet

  validates :ip_address, presence: true
  validates :hostname, domain_name: true
  validates :hw_address, format: {with: MAC_ADDRESS_REGEX}

  validate :ip_address_is_a_valid_ipv4_address
  validate :ip_address_is_within_the_subnet

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

    unless subnet.ip_addr === ip_addr
      errors.add(:ip_address, "is not within the subnets CIDR block")
      return
    end

    if ip_addr < subnet.start_address_ip_addr || ip_addr > subnet.end_address_ip_addr
      errors.add(:ip_address, "is not within the subnet range")
    end
  end
end
