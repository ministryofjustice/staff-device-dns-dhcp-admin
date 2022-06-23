class Api::SubnetStatsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :basic_auth

  def index
    sites = Site.all
    @result = sites.map do |site|
      subnets = site.subnets.sort_by(&:ip_addr)

      subnet_statistics = {}
      subnets.map do |subnet|
        subnet_statistics[subnet.id] = SubnetStatistic.new(
          subnet: subnet,
          leases: UseCases::FetchLeases.new(
            gateway: kea_control_agent_gateway,
            subnet_kea_id: subnet.kea_id
          ).call
        )
      end

    end

    render json: @result.to_json
  end
end
