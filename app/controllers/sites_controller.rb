class SitesController < ApplicationController
  before_action :set_site, only: [:show, :edit, :update, :destroy]

  def index
    @sites = Site.order(:fits_id).all
    @navigation_crumbs = [["Home", root_path]]
    @sites = if params[:query].present?
               # Site.where('name LIKE ? OR fits_id LIKE ?', "%#{params[:query]}%", "%#{params[:query]}%")
               Site.where('name LIKE ? OR fits_id LIKE ? OR id IN (
               SELECT sn.site_id
               FROM subnets s
               INNER JOIN shared_networks sn ON s.shared_network_id = sn.id
               WHERE s.cidr_block LIKE ?
             )', "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%")
             else
               Site.all
             end
  end

  def show
    @subnets = @site.subnets.sort_by(&:ip_addr)

    @subnet_statistics = {}
    @subnets.each do |subnet|
      @subnet_statistics[subnet.id] = SubnetStatistic.new(
        subnet: subnet,
        leases: UseCases::FetchLeases.new(
          gateway: kea_control_agent_gateway,
          subnet_kea_id: subnet.kea_id
        ).call
      )
    end
    @navigation_crumbs = [["Home", root_path], ["DHCP", dhcp_path]]
  end

  def new
    @site = Site.new
    authorize! :create, @site
  end

  def create
    @site = Site.new(site_params)
    authorize! :create, @site
    @result = update_dhcp_config.call(@site, -> { @site.save! })

    if @result.success?
      redirect_to site_path(@site), notice: "Successfully created site. " + CONFIG_UPDATE_DELAY_NOTICE
    else
      render :new
    end
  end

  def edit
    authorize! :update, @site
  end

  def update
    authorize! :update, @site
    @site.assign_attributes(site_params)
    @result = update_dhcp_config.call(@site, -> { @site.save! })

    if @result.success?
      redirect_to site_path(@site), notice: "Successfully updated site. " + CONFIG_UPDATE_DELAY_NOTICE
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @site
    @subnets = @site.subnets.sort_by(&:ip_addr)
    if confirmed?
      if update_dhcp_config.call(@site, -> { @site.destroy }).success?
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
    params.require(:site).permit(:fits_id, :name, :windows_update_delivery_optimisation_enabled)
  end
end
