class Api::DhcpStatsController < ApplicationController
  skip_before_action :authenticate_user!
  http_basic_authenticate_with name: ENV["API_BASIC_AUTH_USERNAME"], password: ENV["API_BASIC_AUTH_PASSWORD"]

  def index
    sites = Site.includes(subnets: [:exclusions, :reservations]).all

    @sites_list = sites.map do |site|
      subnets = site.subnets.sort_by(&:ip_addr)

      subnets_list = {}

      subnets.map do |subnet|
        stats = SubnetStatistic.new(
          subnet: subnet,
          leases: UseCases::FetchLeases.new(
            gateway: kea_control_agent_gateway,
            subnet_kea_id: subnet.kea_id
          ).call
        )

        subnets_list[site.name] = {
          subnets: subnets.map do |subnet|
            {
              subnet_id: subnet.id,
              cidr_block: subnet.cidr_block,
              reservations_count: subnet.reservations_count,
              remaining_ips_count: stats.num_remaining_ips,
              leases_count: stats.num_of_used_leases,
              usage_percentage: stats.percentage_used
            }
          end
        }
      end

      subnets_list
    end

    @result = {sites: @sites_list}

    render json: JSON.pretty_generate(@result)
  end
end
