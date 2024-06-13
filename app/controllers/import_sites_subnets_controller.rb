  class ImportSitesSubnetsController < ApplicationController
  def index
    authorize! :manage, :import_sites
  end

  def create
    authorize! :manage, :import_sites
    @result = update_dhcp_config.call(nil, -> { csv_import_subnets })
    if @result.success?
      redirect_to import_sites_path, notice: "Successfully ran the Subnets import."
    else
      render :index
    end
  end

  private

  def import_params
    params.require(:import).permit(:file)
  end

  def csv_import_subnets
    require 'csv'
    file = File.open(import_params[:file])
    csv = CSV.parse(file, headers: true, col_sep: ',')
    csv.each do |row|
      @site = Site.where(fits_id: row['FITSID']).first!

      @shared_network = SharedNetwork.new(site_id: @site.id)
      @shared_network.save!

      subnet_hash = {}
      subnet_hash[:cidr_block] = row['cidr_block']
      subnet_hash[:start_address] = row['start_address']
      subnet_hash[:end_address] = row['end_address']
      subnet_hash[:routers] = row['routers']
      subnet_hash[:shared_network] = @shared_network

      @subnet = Subnet.find_or_create_by!(subnet_hash)
    end
  end

end
