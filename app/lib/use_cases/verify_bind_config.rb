module UseCases
  class VerifyBindConfig
    def initialize(bind_verifier_gateway:)
      @bind_verifier_gateway = bind_verifier_gateway
    end

    def call(config)
      bind_verifier_gateway.verify_config(config)
      Result.new
    rescue Gateways::BindVerifier::ConfigurationError => error
      Result.new(error)
    end

    private

    attr_reader :bind_verifier_gateway
  end
end
