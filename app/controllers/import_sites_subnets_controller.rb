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
    params.require(:import).permit(:file, :fits_id, :cidr_block, :start_address, :end_address, :routers)
  end

  def csv_import_subnets
    require 'csv'
    file = File.open(import_params[:file])
    csv = CSV.parse(file, headers: true, col_sep: ',')
    csv.each do |row|
      subnet_hash = {}
      subnet_hash[:fits_id] = row['FITSID']
      subnet_hash[:cidr_block] = row['cidr_block']
      subnet_hash[:start_address] = row['start_address']
      subnet_hash[:end_address] = row['end_address']
      subnet_hash[:routers] = row['routers']
      Subnet.find_or_create_by!(subnet_hash)
    end
  end

end
