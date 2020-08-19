class HomeController < ApplicationController
  def show
    # temporary location for testing until we have a way to publish configurations
    UseCases::PublishKeaConfig.new(
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("KEA_CONFIG_BUCKET"),
        key: "config.json"
      ),
      generate_config: UseCases::GenerateKeaConfig.new
    ).execute
  end
end
