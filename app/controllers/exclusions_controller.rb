class ExclusionsController < ApplicationController
  before_action :set_subnet
  before_action :set_exclusion, only: [:edit, :update, :destroy]

  def new
    @exclusion = @subnet.exclusions.build
    authorize! :create, @exclusion
  end

  def create
    @exclusion = @subnet.exclusions.build(exclusion_params)
    authorize! :create, @exclusion

    if update_dhcp_config.call(@exclusion, -> { @exclusion.save })
      redirect_to subnet_path(@exclusion.subnet), notice: "Successfully created exclusion." + CONFIG_UPDATE_DELAY_NOTICE
    else
      render :new
    end
  end

  def edit
    authorize! :update, @option
    @global_option = GlobalOption.first
  end

  def update
    authorize! :update, @option
    @option.assign_attributes(option_params)

    if update_dhcp_config.call(@option, -> { @option.save })
      redirect_to subnet_path(@option.subnet), notice: "Successfully updated options." + CONFIG_UPDATE_DELAY_NOTICE
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @option
    if confirmed?
      if update_dhcp_config.call(@option, -> { @option.destroy })
        redirect_to subnet_path(@option.subnet), notice: "Successfully deleted option." + CONFIG_UPDATE_DELAY_NOTICE
      else
        redirect_to subnet_path(@option.subnet), error: "Failed to delete the option"
      end
    else
      render "destroy"
    end
  end

  private

  def subnet_id
    params.fetch(:subnet_id)
  end

  def set_subnet
    @subnet = Subnet.find(subnet_id)
  end

  def set_exclusion
    exclusion = @subnet.exclusion
  end

  def exclusion_params
    params.require(:exclusion).permit(:start_address, :end_address)
  end

  def confirmed?
    params.fetch(:confirm, false)
  end
end
