class LeasesController < ApplicationController
  def index
    @subnet = Subnet.find(params[:subnet_id])
    @leases = UseCases::FetchLeases.new(
      gateway: Gateways::KeaControlAgent.new,
      subnet_kea_id: @subnet.kea_id
    ).execute
  end
end
