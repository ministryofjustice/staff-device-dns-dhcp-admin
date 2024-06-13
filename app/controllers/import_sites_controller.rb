class ImportSitesController < ApplicationController
  before_action :authorize_import_sites

  def index; end

  def new; end

  def create
    if csv_import_sites
      redirect_to import_sites_path, notice: "Successfully ran the sites import."
    else
      flash[:alert] = "Failed to import sites."
      render :new
    end
  rescue StandardError => e
    flash[:alert] = "An error occurred: #{e.message}"
    render :new
  end

  def run_update_dhcp_config
    @site = Site.first
    dhcp_result = update_dhcp_config.call(@site, -> { @site.save! })

    if dhcp_result && dhcp_result.success?
      redirect_to import_sites_path, notice: "Successfully updated the DHCP (KEA) Config."
    else
      flash[:alert] = "Failed to update the DHCP (KEA) Config." unless import_result&.success?
      render :index
    end
  rescue StandardError => e
    flash[:alert] = "An error occurred: #{e.message}"
    render :index
  end

  private

  def authorize_import_sites
    authorize! :manage, :import_sites
  end

  def import_params
    params.require(:import).permit(:file)
  end

  def csv_import_sites
    require 'csv'
    file = import_params[:file]

    if file.nil?
      raise "No file uploaded"
    end

    CSV.open(file.path, headers: true, col_sep: ',') do |csv|
      ActiveRecord::Base.transaction do
        csv.each do |row|
          create_or_update_site(row)
        end
      end
    end
    true
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    raise "Database error: #{e.message}"
  rescue CSV::MalformedCSVError => e
    raise "CSV parsing error: #{e.message}"
  rescue StandardError => e
    raise "An unexpected error occurred: #{e.message}"
  end

  def create_or_update_site(row)
    site_attributes = {
      name: row['name'],
      fits_id: row['fits_id'],
      windows_update_delivery_optimisation_enabled: row['windows_opt']
    }

    Site.find_or_create_by!(site_attributes)
  end
end
