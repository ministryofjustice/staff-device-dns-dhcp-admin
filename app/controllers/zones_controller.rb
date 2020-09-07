class ZonesController < ApplicationController
  def index
    @zones = Zone.select(:name, :forwarders, :purpose).all
  end
end
