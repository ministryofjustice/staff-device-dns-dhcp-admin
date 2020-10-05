class SubnetsController < ApplicationController
  before_action :set_site, only: [:new, :create]
  before_action :set_subnet, only: [:show, :edit, :update, :destroy]

  def new
    @subnet = @site.subnets.build
    authorize! :create, @subnet
  end

  def create
    @subnet = @site.subnets.build(subnet_params)
    authorize! :create, @subnet
    if @subnet.save
      publish_kea_config
      deploy_service
      redirect_to @site, notice: "Successfully created subnet"
    else
      render :new
    end
  end

  def show
  end

  def edit
    authorize! :update, @subnet
  end

  def update
    authorize! :update, @subnet
    if @subnet.update(subnet_params)
      publish_kea_config
      deploy_service
      redirect_to @subnet.site, notice: "Successfully updated subnet"
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @subnet
    if confirmed?
      if @subnet.destroy
        publish_kea_config
        deploy_service
        redirect_to @subnet.site, notice: "Successfully deleted subnet"
      else
        redirect_to @subnet.site, error: "Failed to delete the subnet"
      end
    else
      render "subnets/destroy"
    end
  end

  private

  def set_site
    @site = Site.find(site_id)
  end

  def site_id
    params.fetch(:site_id)
  end

  def set_subnet
    @subnet = Subnet.find(subnet_id)
  end

  def subnet_id
    params.fetch(:id)
  end

  def confirmed?
    params.fetch(:confirm, false)
  end

  def subnet_params
    params.require(:subnet).permit(:cidr_block, :start_address, :end_address)
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

  def deploy_service
    UseCases::DeployService.new(
      ecs_gateway: Gateways::Ecs.new(
        cluster_name: ENV.fetch("DHCP_CLUSTER_NAME"),
        service_name: ENV.fetch("DHCP_SERVICE_NAME"),
        aws_config: Rails.application.config.ecs_aws_config
      )
    ).execute
  end
end
