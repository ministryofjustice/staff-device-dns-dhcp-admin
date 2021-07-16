module UseCases
  class DestroyLease
    def initialize(gateway:, lease_ip_address:)
      @gateway = gateway
      @lease_ip_address = lease_ip_address
    end

    def call
      gateway.destroy_lease(lease_ip_address)
      true
    end

    private

    attr_reader :gateway, :lease_ip_address
  end
end
