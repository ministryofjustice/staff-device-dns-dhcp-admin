require 'csv'

class LeasesController < ApplicationController
  def index
    @subnet = Subnet.find(params[:subnet_id])
    @leases = UseCases::FetchLeases.new(
      gateway: kea_control_agent_gateway,
      subnet_kea_id: @subnet.kea_id
    ).call
    @navigation_crumbs = [["Home", root_path], ["DHCP", dhcp_path], ["Site", @subnet.site], ["Subnet", @subnet]]
  end

  def destroy
    @lease = UseCases::FetchLease.new(
      lease_ip_address: lease_ip_address,
      gateway: kea_control_agent_gateway
    ).call

    if confirmed?
      UseCases::DestroyLease.new(
        lease_ip_address: lease_ip_address,
        gateway: kea_control_agent_gateway
      ).call
      redirect_to subnet_leases_path(@lease.subnet), notice: "Successfully deleted lease. "
    else
      render :destroy
    end
  end

  def export

    @subnet = Subnet.find(params[:subnet_id])
    @leases = UseCases::FetchLeases.new(
      gateway: kea_control_agent_gateway,
      subnet_kea_id: @subnet.kea_id
    ).call 

    column_names = ["HW address", "IP address", "Hostname", "State"]

    content = CSV.generate do |csv|
      csv << column_names
      @leases.each do |lease|
        csv << lease.lease_details
      end
    end
    
    send_data content, :filename => "#{@subnet.start_address}.csv"

  end

  private

  def lease_ip_address
    params.fetch(:id).tr("-", ".")
  end

  def confirmed?
    params.fetch(:confirm, false)
  end
end
