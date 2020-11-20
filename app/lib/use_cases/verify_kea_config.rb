module UseCases
  class VerifyKeaConfig
    def initialize(kea_control_agent_gateway:)
      @kea_control_agent_gateway = kea_control_agent_gateway
    end

    def call(config)
      kea_control_agent_gateway.verify_config(config)
      true
    rescue Gateways::KeaControlAgent::InternalError
      false
    end

    private

    attr_reader :kea_control_agent_gateway
  end
end
