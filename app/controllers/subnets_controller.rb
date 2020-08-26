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
      redirect_to subnets_path, notice: "Successfully created subnet"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @subnet.update(subnet_params)
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
end
