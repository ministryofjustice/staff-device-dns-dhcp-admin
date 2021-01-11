class UseCases::PublishKeaConfig
  include ActiveSupport::Benchmarkable

  def initialize(destination_gateway:, logger: nil)
    @destination_gateway = destination_gateway
    @logger = logger
  end

  def call(payload)
    benchmark "Benchmark: UseCases::PublishKeaConfig", level: :debug do
      destination_gateway.write(data: JSON.generate(payload))
    end
  end

  private

  attr_reader :destination_gateway,
    :logger
end
