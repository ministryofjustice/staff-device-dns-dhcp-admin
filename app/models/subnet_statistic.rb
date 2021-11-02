class SubnetStatistic
  attr_reader :subnet,
    :leases

  def initialize(subnet:, leases:)
    @subnet = subnet
    @leases = leases
  end

  def percentage_used
    (unreserved_leases.count.to_f / dynamically_allocatable_ips.to_f) * 100
  end

  def num_of_used_leases
    leases.count 
  end 

  def num_remaining_ips
    dynamically_allocatable_ips - unreserved_leases.count
  end

  def reservations_outside_of_exclusions
    @reservations_outside_of_exclusions ||= subnet.reservations.select do |reservation|
      subnet.exclusions.none? do |exclusion|
        exclusion.contains_ip_address? reservation.ip_address
      end
    end
  end

  def leases_not_in_exclusion_zones
    @leases_not_in_exclusion_zones ||= leases.select do |lease|
      subnet.exclusions.none? do |exclusion|
        exclusion.contains_ip_address? lease.ip_address
      end
    end
  end

  def leased_reserved_ip_addresses
    @leased_reserved_ip_addresses ||= leases.select do |lease|
      reservations_outside_of_exclusions
        .map(&:ip_address)
        .include?(lease.ip_address)
    end
  end

  def unreserved_leases
    @unreserved_leases ||= leases_not_in_exclusion_zones - leased_reserved_ip_addresses
  end

  def dynamically_allocatable_ips
    @dynamically_allocatable_ips ||= subnet.total_addresses - reservations_outside_of_exclusions.count
  end
end
