class ExclusionsController < ApplicationController
  before_action :set_subnet, except: [:show, :destroy]
  before_action :set_exclusion, only: [:destroy]

  def new
    @exclusion = @subnet.exclusions.build
    authorize! :create, @exclusion
  end

  def create
    @exclusion = @subnet.exclusions.build(exclusion_params)
    authorize! :create, @exclusion
    @result = update_dhcp_config.call(@exclusion, -> { @exclusion.save! })

    if @result.success?
      redirect_to subnet_path(@exclusion.subnet), notice: "Successfully created exclusion." + CONFIG_UPDATE_DELAY_NOTICE
    else
      render :new
    end
  end

  def destroy
    authorize! :destroy, @exclusion
    if confirmed?
      if update_dhcp_config.call(@exclusion, -> { @exclusion.destroy }).success?
        redirect_to subnet_path(@exclusion.subnet), notice: "Successfully deleted exclusion." + CONFIG_UPDATE_DELAY_NOTICE
      else
        redirect_to subnet_path(@exclusion.subnet), error: "Failed to delete the exclusion"
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
    @exclusion = Exclusion.find(exclusion_id)
  end

  def exclusion_id
    params.fetch(:id)
  end

  def exclusion_params
    params.require(:exclusion).permit(:start_address, :end_address)
  end

  def confirmed?
    params.fetch(:confirm, false)
  end
end
