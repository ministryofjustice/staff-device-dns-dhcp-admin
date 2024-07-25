class ImportSitesReservationsController < ApplicationController
  before_action :authorize_import_sites

  def index;
    @navigation_crumbs = [["Home", root_path], ["Import", import_sites_path]]
  end

  def create
    @navigation_crumbs = [["Home", root_path], ["Import", import_sites_path]]
    if csv_import_reservations
      redirect_to import_sites_path, notice: "Successfully ran the Reservations import."
    else
      flash[:alert] = "Failed to import Reservations."
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

  def csv_import_reservations
    require 'csv'
    file = import_params[:file]

    if file.nil?
      raise "No file uploaded"
    end

    CSV.open(file.path, headers: true, col_sep: ',') do |csv|
      ActiveRecord::Base.transaction do
        csv.each do |row|
          @subnet = Subnet.where(cidr_block: row['cidr_block']).first!
          create_or_update_reservation(row, @subnet.id)
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

  def create_or_update_reservation(row, subnet_id)
    reservation_attributes = {
      subnet_id: subnet_id,
      hw_address: row['hw_address'],
      ip_address: row['ip_address'],
      hostname: row['hostname'],
      description: row['description'],
      hostname: row['hostname']
    }

    Reservation.find_or_create_by!(reservation_attributes)
  end
end
