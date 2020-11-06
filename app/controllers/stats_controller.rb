class StatsController < ApplicationController
  def dhcp
    render json: Gateways::KeaControlAgent.new.fetch_stats
  end
end
