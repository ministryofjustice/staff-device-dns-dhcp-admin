class ZonesController < ApplicationController
  before_action :set_zone, only: [:edit, :update, :destroy]

  def index
    @zones = Zone.select(:id, :name, :forwarders, :purpose).all
    @navigation_crumbs = [["Home", root_path]]
  end

  def new
    @zone = Zone.new
    authorize! :create, @zone
  end

  def create
    @zone = Zone.new(zone_params)
    authorize! :create, @zone
    @result = update_dns_config.call(@zone, -> { @zone.save! })

    if @result.success?
      redirect_to dns_path, notice: "Successfully created zone"
    else
      render :new
    end
  end

  def edit
    authorize! :update, @zone
  end

  def update
    authorize! :update, @zone
    @zone.assign_attributes(zone_params)
    @result = update_dns_config.call(@zone, -> { @zone.save! })

    if @result.success?
      redirect_to dns_path, notice: "Successfully updated zone"
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @zone
    if confirmed?
      if update_dns_config.call(@zone, -> { @zone.destroy })
        redirect_to dns_path, notice: "Successfully deleted zone"
      else
        redirect_to dns_path, error: "Failed to delete the zone"
      end
    end
  end

  private

  def set_zone
    @zone = Zone.find(zone_id)
  end

  def zone_id
    params.fetch(:id)
  end

  def confirmed?
    params.fetch(:confirm, false)
  end

  def zone_params
    params.require(:zone).permit(:name, :forwarders, :purpose)
  end

  def publish_bind_config
    UseCases::PublishBindConfig.new(
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("BIND_CONFIG_BUCKET"),
        key: "named.conf",
        aws_config: Rails.application.config.s3_aws_config,
        content_type: "application/octet-stream"
      )
    )
  end

  def generate_bind_config
    UseCases::GenerateBindConfig.new(
      zones: Zone.all,
      pdns_ips: ENV["PDNS_IPS"],
      private_zone: ENV["PRIVATE_ZONE"]
    )
  end

  def bind_verifier_gateway
    Gateways::BindVerifier.new(
      logger: Rails.logger
    )
  end

  def verify_bind_config
    UseCases::VerifyBindConfig.new(
      bind_verifier_gateway: bind_verifier_gateway
    )
  end

  def deploy_dns_service
    UseCases::DeployService.new(
      ecs_gateway: Gateways::Ecs.new(
        cluster_name: ENV.fetch("DNS_CLUSTER_NAME"),
        service_name: ENV.fetch("DNS_SERVICE_NAME"),
        aws_config: Rails.application.config.ecs_aws_config
      )
    )
  end

  def update_dns_config
    UseCases::TransactionallyUpdateDnsConfig.new(
      generate_bind_config: -> { generate_bind_config.call },
      verify_bind_config: verify_bind_config,
      publish_bind_config: publish_bind_config,
      deploy_dns_service: deploy_dns_service
    )
  end
end
