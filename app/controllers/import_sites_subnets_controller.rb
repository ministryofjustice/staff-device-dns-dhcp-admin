class ImportSitesSubnetsController < ApplicationController
  before_action :authorize_import_sites

  def index;
    @navigation_crumbs = [["Home", root_path], ["Import", import_sites_path]]
  end

  def create
    @navigation_crumbs = [["Home", root_path], ["Import", import_sites_path]]
    if csv_import_subnets
      redirect_to import_sites_path, notice: "Successfully ran the Subnets import."
    else
      flash[:alert] = "Failed to import subnets."
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

  def csv_import_subnets
    require 'csv'
    file = import_params[:file]

    if file.nil?
      raise "No file uploaded"
    end

    CSV.open(file.path, headers: true, col_sep: ',') do |csv|
      ActiveRecord::Base.transaction do
        csv.each do |row|
          site = Site.find_by!(fits_id: row['fits_id'])
          shared_network = create_shared_network(site)
          create_or_update_subnet(row, shared_network)
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

  def create_shared_network(site)
    SharedNetwork.create!(site_id: site.id)
  end

  def create_or_update_subnet(row, shared_network)
    subnet_attributes = {
      cidr_block: row['cidr_block'],
      start_address: row['start_address'],
      end_address: row['end_address'],
      routers: row['routers'],
      shared_network: shared_network
    }

    Subnet.find_or_create_by!(subnet_attributes)
  end
end
