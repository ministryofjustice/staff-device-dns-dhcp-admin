class Subnet < ApplicationRecord
  def ip_addr
    IPAddr.new(cidr_block)
  end
end
