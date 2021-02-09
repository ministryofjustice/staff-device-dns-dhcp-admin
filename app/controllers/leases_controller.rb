class LeasesController < ApplicationController

  add_breadcrumb "Home", :root_path
  add_breadcrumb "DHCP", :dhcp_path

  def index
    @subnet = Subnet.find(params[:subnet_id])
    @leases = UseCases::FetchLeases.new(
      gateway: kea_control_agent_gateway,
      subnet_kea_id: @subnet.kea_id
    ).call
    add_breadcrumb "Site #{@subnet.site.name}", @subnet.site
    add_breadcrumb "Subnet #{@subnet.cidr_block}", @subnet
  end
end
