class SubnetsController < ApplicationController
  before_action :set_site, only: [:new, :create]
  before_action :set_subnet, only: [:show, :edit, :update, :destroy]

  def new
    @subnet = @site.subnets.build
    authorize! :create, @subnet
  end

  def create
    @subnet = @site.subnets.build(subnet_params)
    authorize! :create, @subnet

    if save_dhcp_record(-> { @subnet.save })
      redirect_to @site, notice: "Successfully created subnet"
    else
      render :new
    end
  end

  def show
  end

  def edit
    authorize! :update, @subnet
  end

  def update
    authorize! :update, @subnet
    @subnet.assign_attributes(subnet_params)

    if save_dhcp_record(-> { @subnet.save })
      redirect_to @subnet.site, notice: "Successfully updated subnet"
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @subnet
    if confirmed?
      if save_dhcp_record(-> { @subnet.destroy })
        redirect_to @subnet.site, notice: "Successfully deleted subnet"
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
    params.require(:subnet).permit(:cidr_block, :start_address, :end_address)
  end
end
