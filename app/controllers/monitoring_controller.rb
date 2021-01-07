class MonitoringController < ApplicationController
  skip_before_action :authenticate_user!, only: [:healthcheck]

  def healthcheck
    render body: "Healthy"
  end

  def lease_stats
    render body: kea_control_agent_gateway.fetch_lease_stats
  end
end
