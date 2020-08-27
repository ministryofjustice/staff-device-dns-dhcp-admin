class SubnetsController < ApplicationController
  before_action :set_subnet, only: [:edit, :update]

  def index
    @subnets = Subnet.all.sort_by(&:ip_addr)
  end

  def new
    @subnet = Subnet.new
  end

  def create
    @subnet = Subnet.new(subnet_params)
    if @subnet.save
      publish_kea_config
      redirect_to subnets_path, notice: "Successfully created subnet"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @subnet.update(subnet_params)
      publish_kea_config
      redirect_to subnets_path, notice: "Successfully updated subnet"
    else
      render :edit
    end
  end

  private

  def set_subnet
    @subnet = Subnet.find(subnet_id)
  end

  def subnet_id
    params.fetch(:id)
  end

  def subnet_params
    params.require(:subnet).permit(:cidr_block, :start_address, :end_address)
  end

  def publish_kea_config
    UseCases::PublishKeaConfig.new(
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("KEA_CONFIG_BUCKET"),
        key: "config.json",
        aws_config: Rails.application.config.s3_aws_config
      ),
      generate_config: UseCases::GenerateKeaConfig.new(subnets: Subnet.all)
    ).execute
  end
end
