module UseCases
  class VerifyBindConfig
    def initialize(bind_verifier_gateway:)
      @bind_verifier_gateway = bind_verifier_gateway
    end

    def call(config)
      bind_verifier_gateway.verify_config(config)
      Result.new
    rescue Gateways::BindVerifier::InternalError => error
      Result.new(error)
    end

    private

    attr_reader :bind_verifier_gateway

    class Result
      attr_reader :error

      def initialize(error = nil)
        @error = error
      end

      def success?
        error.nil?
      end
    end
  end
end
