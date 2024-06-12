  class ImportSitesController < ApplicationController
  def index
    authorize! :manage, :import_sites
  end

  def new
    authorize! :manage, :import_sites
  end

  def create
    authorize! :manage, :import_sites
    @result = update_dhcp_config.call(nil, -> { csv_import_sites })
    if @result.success?
      redirect_to import_sites_path, notice: "Successfully ran the sites import."
    else
      render :new
    end
  end


  private

  def import_params
    params.require(:import).permit(:file, :name, :fits_id)
  end

  def csv_import_sites
    require 'csv'
    file = File.open(import_params[:file])
    csv = CSV.parse(file, headers: true, col_sep: ',')
    csv.each do |row|
      site_hash = {}
      site_hash[:name] = row['SITENAME']
      site_hash[:fits_id] = row['FITSID']
      site_hash[:windows_update_delivery_optimisation_enabled] = row['windows_opt']
      Site.find_or_create_by!(site_hash)
    end
  end

end
