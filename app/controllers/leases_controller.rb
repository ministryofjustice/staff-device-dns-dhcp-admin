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
    render :destroy
  end
  
  private

  def lease_ip_address
    params.fetch(:id).gsub("-",".")
  end
end
