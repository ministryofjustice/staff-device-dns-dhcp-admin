class SearchController < ApplicationController
  def index
    @reservations = {}
    @navigation_crumbs = [["Home", root_path]]
    @reservations = if params[:query].present?
                      Site.with_mac_search(params[:query])
                    else
                       Site.joins("INNER JOIN shared_networks ON shared_networks.site_id = sites.id INNER JOIN subnets ON subnets.shared_network_id = shared_networks.id INNER JOIN reservations ON reservations.subnet_id = subnets.id")
                           .select('sites.fits_id, sites.name, subnets.cidr_block, reservations.hw_address, reservations.ip_address, reservations.hostname,reservations.id')
                    end
  end


end
