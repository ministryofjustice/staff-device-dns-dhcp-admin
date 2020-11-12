class UseCases::PublishBindConfig
  def initialize(destination_gateway:, generate_config:)
    @destination_gateway = destination_gateway
    @generate_config = generate_config
  end

  def call
    payload = generate_config.call
    destination_gateway.write(data: payload)
  end

  private

  attr_reader :generate_config, :destination_gateway
end
