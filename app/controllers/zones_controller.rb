class ZonesController < ApplicationController
  before_action :set_zone, only: [:edit, :update, :destroy]

  def index
    @zones = Zone.select(:id, :name, :forwarders, :purpose).all
  end

  def new
    @zone = Zone.new
    authorize! :create, @zone
  end

  def create
    @zone = Zone.new(zone_params)
    authorize! :create, @zone
    if @zone.save
      publish_bind_config
      deploy_dns_service
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
    if @zone.update(zone_params)
      publish_bind_config
      deploy_dns_service
      redirect_to dns_path, notice: "Successfully updated DNS zone"
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @zone
    if confirmed?
      if @zone.destroy
        publish_bind_config
        deploy_dns_service
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
      ),
      generate_config: UseCases::GenerateBindConfig.new(zones: Zone.all, pdns_ips: ENV["PDNS_IPS"])
    ).execute
  end
end
