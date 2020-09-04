class Subnet < ApplicationRecord
  KEA_SUBNET_ID_OFFSET = 1000

  validates :cidr_block, presence: true
  validates :start_address, presence: true
  validates :end_address, presence: true

  validate :cidr_block_is_a_valid_ipv4_subnet, :start_address_is_a_valid_ipv4_address,
    :end_address_is_a_valid_ipv4_address

  def ip_addr
    IPAddr.new(cidr_block)
  end

  def kea_id
    id + KEA_SUBNET_ID_OFFSET
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
end
