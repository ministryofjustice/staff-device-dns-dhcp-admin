class SubnetsController < ApplicationController
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

  private

  def subnet_params
    params.require(:subnet).permit(:cidr_block, :start_address, :end_address)
  end
end
