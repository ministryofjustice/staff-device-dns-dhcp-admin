class ZonesController < ApplicationController
  before_action :set_zone, only: [:edit, :update, :destroy]

  def index
    @zones = Zone.select(:id, :name, :forwarders, :purpose).all
  end

  def new
    @zone = Zone.new
  end

  def create
    @zone = Zone.new(zone_params)
    if @zone.save
      publish_bind_config
      redirect_to zones_path, notice: "Successfully created zone"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @zone.update(zone_params)
      publish_bind_config
      redirect_to zones_path, notice: "Successfully updated DNS zone"
    else
      render :edit
    end
  end

  def destroy
    if confirmed?
      if @zone.destroy
        publish_bind_config
        redirect_to zones_path, notice: "Successfully deleted zone"
      else
        redirect_to zones_path, error: "Failed to delete the zone"
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
      generate_config: UseCases::GenerateBindConfig.new
    ).execute
  end
end
