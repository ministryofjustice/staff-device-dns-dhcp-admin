class ImportSitesSubnetsController < ApplicationController
  before_action :authorize_import_sites

  def index
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

    csv = CSV.open(file.path, headers: true, col_sep: ',')
    begin
      ActiveRecord::Base.transaction do
        csv.each do |row|
          site = Site.find_by!(fits_id: row['fits_id'])
          shared_network = create_shared_network(site)
          create_or_update_subnet(row, shared_network)

          ##Experimental
          @subnet = Subnet.where(cidr_block: row['cidr_block']).first!
          if row['exclusion_start_address'].present?
            create_or_update_exclusions(row, @subnet.id)
          end
          if row['domain_name'].present?
            create_or_update_option(row, @subnet.id)
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
    ensure
      csv.close if csv
    end
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

  ##Experimental
  def create_or_update_exclusions(row, subnet_id)
    exclusion_attributes = {
      subnet_id: subnet_id,
      start_address: row['exclusion_start_address'],
      end_address: row['exclusion_end_address']
    }

    Exclusion.find_or_create_by!(exclusion_attributes)
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
