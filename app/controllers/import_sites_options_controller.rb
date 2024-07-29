class ImportSitesOptionsController < ApplicationController
  before_action :authorize_import_sites
  
  def index;
    @navigation_crumbs = [["Home", root_path], ["Import", import_sites_path]]
  end

  def create
    @navigation_crumbs = [["Home", root_path], ["Import", import_sites_path]]
    if csv_import_options
      redirect_to import_sites_path, notice: "Successfully ran the Subnet Options import."
    else
      flash[:alert] = "Failed to import Subnet Options."
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

  def csv_import_options
    require 'csv'
    file = import_params[:file]

    if file.nil?
      raise "No file uploaded"
    end

    csv = CSV.open(file.path, headers: true, col_sep: ',')
    begin
      ActiveRecord::Base.transaction do
        csv.each do |row|
          @subnet = Subnet.where(cidr_block: row['cidr_block']).first!
          create_or_update_option(row, @subnet.id)
        end
      end
      true
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      raise "Database error: #{e.message}"
    rescue CSV::MalformedCSVError => e
      raise "CSV parsing error: #{e.message}"
    rescue StandardError => e
      raise "An unexpected error occurred: #{e.message}"
    ensure
      csv.close if csv
    end
  end

  def create_or_update_option(row, subnet_id)
    option_attributes = {
      subnet_id: subnet_id,
      domain_name_servers: row['domain_name_servers'],
      domain_name: row['domain_name'],
      valid_lifetime: row['valid_lifetime'],
      valid_lifetime_unit: row['valid_lifetime_unit']
    }

    Option.find_or_create_by!(option_attributes)
  end
end
