class SubnetStatistic
  attr_reader :subnet,
              :leases

  def initialize(subnet:, leases:)
    @subnet = subnet
    @leases = leases
  end

  def num_remaining_ips
    (subnet.total_addresses - leases.count) - subnet.reservations.count
  end
end