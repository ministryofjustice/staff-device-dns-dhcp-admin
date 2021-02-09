class SitesController < ApplicationController
  before_action :set_site, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "Home", :root_path

  def index
    @sites = Site.order(:fits_id).all
    @navigation_crumbs = [["Home", root_path]]
  end

  def show
    @subnets = @site.subnets.sort_by(&:ip_addr)
    add_breadcrumb "DHCP", :dhcp_path
  end

  def new
    @site = Site.new
    authorize! :create, @site
    add_breadcrumb "DHCP", :dhcp_path
  end

  def create
    @site = Site.new(site_params)
    authorize! :create, @site

    if update_dhcp_config.call(@site, -> { @site.save })
      redirect_to site_path(@site), notice: "Successfully created site. " + CONFIG_UPDATE_DELAY_NOTICE
    else
      render :new
    end
  end

  def edit
    authorize! :update, @site
    add_breadcrumb "DHCP", :dhcp_path
  end

  def update
    authorize! :update, @site
    @site.assign_attributes(site_params)

    if update_dhcp_config.call(@site, -> { @site.save })
      redirect_to site_path(@site), notice: "Successfully updated site. " + CONFIG_UPDATE_DELAY_NOTICE
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @site
    add_breadcrumb "DHCP", :dhcp_path
    @subnets = @site.subnets.sort_by(&:ip_addr)
    if confirmed?
      if update_dhcp_config.call(@site, -> { @site.destroy })
        redirect_to dhcp_path, notice: "Successfully deleted site. " + CONFIG_UPDATE_DELAY_NOTICE
      else
        redirect_to dhcp_path, error: "Failed to delete the site"
      end
    else
      render "sites/destroy"
    end
  end

  private

  def set_site
    @site = Site.find(site_id)
  end

  def site_id
    params.fetch(:id)
  end

  def confirmed?
    params.fetch(:confirm, false)
  end

  def site_params
    params.require(:site).permit(:fits_id, :name)
  end
end
