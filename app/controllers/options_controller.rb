class OptionsController < ApplicationController
  before_action :set_subnet

  def new
    @option = @subnet.build_option
    authorize! :create, @option
  end

  def create
    @option = @subnet.build_option(option_params)
    authorize! :create, @option
    if @option.save
      redirect_to subnet_path(@option.subnet), notice: "Successfully created option"
    else
      render :new
    end
  end

  private

  def subnet_id
    params.fetch(:subnet_id)
  end

  def set_subnet
    @subnet = Subnet.find(subnet_id)
  end

  def option_params
    params.require(:option).permit(:routers, :domain_name_servers, :domain_name)
  end
end
