class UseCases::FetchLeases
  attr_reader :gateway, :subnet_kea_id

  def initialize(gateway:, subnet_kea_id:)
    @gateway = gateway
    @subnet_kea_id = subnet_kea_id
  end

  def call
    gateway.fetch_leases(subnet_kea_id).map do |lease_data|
      Lease.new(
        hw_address: lease_data["hw-address"],
        ip_address: lease_data["ip-address"],
        hostname: lease_data["hostname"]
      )
    end
  end
end
