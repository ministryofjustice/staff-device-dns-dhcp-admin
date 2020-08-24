class Subnet < ApplicationRecord
  validate :cidr_block_is_a_valid_ipv4_subnet, :start_address_is_a_valid_ipv4_address

  def ip_addr
    IPAddr.new(cidr_block)
  end

  private

  def cidr_block_is_a_valid_ipv4_subnet
    unless IPAddress.valid_ipv4_subnet?(cidr_block)
      errors.add(:cidr_block, "is not a valid IPv4 subnet")
    end
  end

  def start_address_is_a_valid_ipv4_address
    unless IPAddress.valid_ipv4?(start_address)
      errors.add(:start_address, "is not a valid IPv4 address")
    end
  end
end
