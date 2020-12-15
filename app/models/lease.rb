class Lease
  attr_reader :hw_address,
    :ip_address,
    :hostname,
    :state

  def initialize(hw_address:, ip_address:, hostname:, state:)
    @hw_address = hw_address
    @ip_address = ip_address
    @hostname = hostname
    @state = state
  end

  def pretty_state
    return "Leased" if state == 0
    return "Declined" if state == 1
    return "Expired / Reclaimed" if state == 2

    "Unknown"
  end
end
