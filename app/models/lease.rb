class Lease
  attr_reader :hw_address,
    :ip_address,
    :hostname

  def initialize(hw_address:, ip_address:, hostname:)
    @hw_address = hw_address
    @ip_address = ip_address
    @hostname = hostname
  end
end
