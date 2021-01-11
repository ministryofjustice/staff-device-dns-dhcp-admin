module UseCases
  class VerifyKeaConfig
    include ActiveSupport::Benchmarkable

    def initialize(kea_control_agent_gateway:, logger: nil)
      @kea_control_agent_gateway = kea_control_agent_gateway
      @logger = logger
    end

    def call(config)
      benchmark "Benchmark: UseCases::VerifyKeaConfig", level: :debug do
        kea_control_agent_gateway.verify_config(config)
        Result.new
      rescue Gateways::KeaControlAgent::InternalError => error
        Result.new(error)
      end
    end

    private

    attr_reader :kea_control_agent_gateway,
      :logger

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
