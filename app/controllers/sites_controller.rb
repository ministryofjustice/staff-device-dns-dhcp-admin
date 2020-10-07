class SitesController < ApplicationController
  before_action :set_site, only: [:show, :edit, :update, :destroy]

  def index
    @sites = Site.order(:fits_id).all
  end

  def show
    @subnets = @site.subnets.sort_by(&:ip_addr)
  end

  def new
    @site = Site.new
    authorize! :create, @site
  end

  def create
    @site = Site.new(site_params)
    authorize! :create, @site
    if @site.save
      publish_kea_config
      deploy_dhcp_service
      redirect_to sites_path, notice: "Successfully created site"
    else
      render :new
    end
  end

  def edit
    authorize! :update, @site
  end

  def update
    authorize! :update, @site
    if @site.update(site_params)
      publish_kea_config
      deploy_dhcp_service
      redirect_to sites_path, notice: "Successfully updated site"
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @site
    @subnets = @site.subnets.sort_by(&:ip_addr)
    if confirmed?
      if @site.destroy
        publish_kea_config
        deploy_dhcp_service
        redirect_to sites_path, notice: "Successfully deleted site"
      else
        redirect_to sites_path, error: "Failed to delete the site"
      end
    else
      render "sites/destroy"
    end
  end

  private

  def set_site
    @site = Site.find(site_id)
  end

  def site_id
    params.fetch(:id)
  end

  def confirmed?
    params.fetch(:confirm, false)
  end

  def site_params
    params.require(:site).permit(:fits_id, :name)
  end

  def publish_kea_config
    UseCases::PublishKeaConfig.new(
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("KEA_CONFIG_BUCKET"),
        key: "config.json",
        aws_config: Rails.application.config.s3_aws_config,
        content_type: "application/json"
      ),
      generate_config: UseCases::GenerateKeaConfig.new(subnets: Subnet.all)
    ).execute
  end
end
