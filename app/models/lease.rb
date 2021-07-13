class Lease
  attr_reader :hw_address,
    :ip_address,
    :hostname,
    :state,
    :kea_subnet_id

  def initialize(hw_address: nil, ip_address: nil, hostname: nil, state: nil, kea_subnet_id: nil)
    @hw_address = hw_address
    @ip_address = ip_address
    @hostname = hostname
    @state = state
    @kea_subnet_id = kea_subnet_id
  end

  def pretty_state
    return "Leased" if state == 0
    return "Declined" if state == 1
    return "Expired / Reclaimed" if state == 2

    "Unknown"
  end

  def subnet
    @subnet ||= Subnet.find_by_kea_id(kea_subnet_id)
  end

  def to_param
    ip_address.gsub(".", "-")
  end
end
