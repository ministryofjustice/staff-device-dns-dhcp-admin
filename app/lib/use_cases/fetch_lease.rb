module UseCases
  class FetchLease
    def initialize(gateway:, lease_ip_address:)
      @gateway = gateway
      @lease_ip_address = lease_ip_address
    end

    def call
      lease_data = gateway.fetch_lease(lease_ip_address)
      Lease.new(
        hw_address: lease_data["hw-address"],
        ip_address: lease_data["ip-address"],
        hostname: lease_data["hostname"],
        state: lease_data["state"],
        kea_subnet_id: lease_data["subnet-id"]
      )
    end

    private

    attr_reader :gateway, :lease_ip_address
  end
end
