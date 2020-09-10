class SubnetsController < ApplicationController
  before_action :set_subnet, only: [:edit, :update, :destroy]

  def index
    @subnets = Subnet.all.sort_by(&:ip_addr)
  end

  def new
    @subnet = Subnet.new
    authorize! :create, @subnet
  end

  def create
    @subnet = Subnet.new(subnet_params)
    authorize! :create, @subnet
    if @subnet.save
      publish_kea_config
      deploy_service
      redirect_to subnets_path, notice: "Successfully created subnet"
    else
      render :new
    end
  end

  def edit
    authorize! :update, @subnet
  end

  def update
    authorize! :update, @subnet
    if @subnet.update(subnet_params)
      publish_kea_config
      deploy_service
      redirect_to subnets_path, notice: "Successfully updated subnet"
    else
      render :edit
    end
  end

  def destroy
    if confirmed?
      if @subnet.destroy
        publish_kea_config
        deploy_service
        redirect_to subnets_path, notice: "Successfully deleted subnet"
      else
        redirect_to subnets_path, error: "Failed to delete the subnet"
      end
    else
      render "subnets/destroy"
    end
  end

  private

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
