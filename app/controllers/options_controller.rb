class OptionsController < ApplicationController
  before_action :set_subnet
  before_action :set_option, only: [:edit, :update, :destroy]

  def new
    @option = @subnet.build_option
    authorize! :create, @option
  end

  def create
    @option = @subnet.build_option(option_params)
    authorize! :create, @option

    if save_dhcp_record(@option)
      redirect_to subnet_path(@option.subnet), notice: "Successfully created options"
    else
      render :new
    end
  end

  def edit
    authorize! :update, @option
  end

  def update
    authorize! :update, @option
    @option.assign_attributes(option_params)

    if save_dhcp_record(@option)
      redirect_to subnet_path(@option.subnet), notice: "Successfully updated options"
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @option
    if confirmed?
      if @option.destroy
        config = generate_kea_config
        publish_kea_config(config)
        deploy_dhcp_service
        redirect_to subnet_path(@option.subnet), notice: "Successfully deleted option"
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

  def set_option
    @option = @subnet.option
  end

  def option_params
    params.require(:option).permit(:routers, :domain_name_servers, :domain_name, :valid_lifetime)
  end

  def confirmed?
    params.fetch(:confirm, false)
  end
end
