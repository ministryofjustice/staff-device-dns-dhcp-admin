class ZonesController < ApplicationController
  def index
    @zones = Zone.select(:name, :forwarders, :purpose).all
  end

  def new
    @zone = Zone.new
  end

  def create
    @zone = Zone.new(zone_params)
    if @zone.save
      redirect_to zones_path, notice: "Successfully created zone"
    else
      render :new
    end
  end

  private

  def zone_params
    params.require(:zone).permit(:name, :forwarders, :purpose)
  end
end
