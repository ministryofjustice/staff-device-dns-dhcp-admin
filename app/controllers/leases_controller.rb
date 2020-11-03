class LeasesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    render json: Gateways::KeaControlAgent.new.fetch_leases
  end
end
