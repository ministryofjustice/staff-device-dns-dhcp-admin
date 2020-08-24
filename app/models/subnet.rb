class Subnet < ApplicationRecord
  validate :cidr_block_is_a_valid_ipv4_subnet

  def ip_addr
    IPAddr.new(cidr_block)
  end

  def cidr_block_is_a_valid_ipv4_subnet
    unless IPAddress.valid_ipv4_subnet?(cidr_block)
      errors.add(:cidr_block, "is not a valid IPv4 subnet")
    end
  end
end
