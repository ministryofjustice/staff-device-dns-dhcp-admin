class UseCases::PublishKeaConfig
  def initialize(destination_gateway:)
    @destination_gateway = destination_gateway
  end

  def call(payload)
    destination_gateway.write(data: payload)
  end

  private

  attr_reader :destination_gateway
end
