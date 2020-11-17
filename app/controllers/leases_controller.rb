class LeasesController < ApplicationController
  def index
    @subnet = Subnet.find(params[:subnet_id])
    @leases = UseCases::FetchLeases.new(
      gateway: kea_control_agent_gateway,
      subnet_kea_id: @subnet.kea_id
    ).call
  end
end
