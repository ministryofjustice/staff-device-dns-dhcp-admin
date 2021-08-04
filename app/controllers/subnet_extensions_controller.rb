class SubnetExtensionsController < ApplicationController
  before_action :set_subnet, only: [:new, :create, :update]

  def new
    @extension = @subnet.shared_network.subnets.build
    authorize! :create, @extension
    @global_option = GlobalOption.first
  end

  def create
    @extension = @subnet.shared_network.subnets.build(extension_params)
    authorize! :create, @extension

    if update_dhcp_config.call(@extension, -> { @extension.save })
      redirect_to @extension, notice: "Successfully extended subnet." + CONFIG_UPDATE_DELAY_NOTICE
    else
      @global_option = GlobalOption.first
      render :new
    end
  end

  def update
    @extension = Subnet.find(extension_id)
    authorize! :update, @extension

    if confirmed?
      if update_dhcp_config.call(@extension, -> { UseCases::MoveSubnetToSharedNetwork.new.call(@extension, @subnet.shared_network) })
        redirect_to @subnet, notice: "Successfully extended subnet." + CONFIG_UPDATE_DELAY_NOTICE
      else
        @global_option = GlobalOption.first
        render :new
      end
    else
      render :confirm_update
    end
  end

  private

  def confirmed?
    params.fetch(:confirm, false)
  end

  def set_subnet
    @subnet = Subnet.find(subnet_id)
  end

  def subnet_id
    params.fetch(:subnet_id)
  end

  def extension_id
    params.fetch(:extension_id)
  end

  def extension_params
    params.require(:subnet).permit(:cidr_block, :start_address, :end_address, :routers)
  end
end
