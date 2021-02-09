class SubnetsController < ApplicationController
  before_action :set_site, only: [:new, :create]
  before_action :set_subnet, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "Home", :root_path
  add_breadcrumb "DHCP", :dhcp_path

  def new
    @subnet = @site.subnets.build
    authorize! :create, @subnet
    add_breadcrumb "Site #{@site.name}", @site
  end

  def create
    @subnet = @site.subnets.build(subnet_params)
    authorize! :create, @subnet

    if update_dhcp_config.call(@subnet, -> { @subnet.save })
      redirect_to @subnet, notice: "Successfully created subnet." + CONFIG_UPDATE_DELAY_NOTICE
    else
      render :new
    end
  end

  def show
    add_breadcrumb "Site #{@subnet.site.name}", @subnet.site
  end

  def edit
    authorize! :update, @subnet
    add_breadcrumb "Site #{@subnet.site.name}", @subnet.site
  end

  def update
    authorize! :update, @subnet
    @subnet.assign_attributes(subnet_params)

    if update_dhcp_config.call(@subnet, -> { @subnet.save })
      redirect_to @subnet, notice: "Successfully updated subnet." + CONFIG_UPDATE_DELAY_NOTICE
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @subnet
    add_breadcrumb "Site #{@subnet.site.name}", @subnet.site
    if confirmed?
      if update_dhcp_config.call(@subnet, -> { @subnet.destroy })
        redirect_to @subnet.site, notice: "Successfully deleted subnet." + CONFIG_UPDATE_DELAY_NOTICE
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
    params.require(:subnet).permit(:cidr_block, :start_address, :end_address, :routers)
  end
end
