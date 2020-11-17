module UseCases
  class VerifyKeaConfig
    def initialize(kea_control_agent_gateway:)
      @kea_control_agent_gateway = kea_control_agent_gateway
    end

    def call(config)
      kea_control_agent_gateway.verify_config(config).fetch("result") == 0
    end

    private

    attr_reader :kea_control_agent_gateway
  end
end
