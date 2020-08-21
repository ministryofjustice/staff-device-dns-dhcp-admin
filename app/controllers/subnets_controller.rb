class SubnetsController < ApplicationController
  def index
    @subnets = Subnet.all.sort_by(&:ip_addr)
  end
end
