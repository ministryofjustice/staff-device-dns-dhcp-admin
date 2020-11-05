class LeasesController < ApplicationController
  def index
    render json: Gateways::KeaControlAgent.new.fetch_leases
  end
end
