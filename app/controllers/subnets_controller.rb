class SubnetsController < ApplicationController
  def index
    @subnets = Subnet.all
  end
end
