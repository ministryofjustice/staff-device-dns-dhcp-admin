require "net/http"
require "json"

module Gateways
  class KeaControlAgent
    def fetch_leases(subnet_kea_id)
      req = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
      req.body = {
        command: "lease4-get-all",
        service: ["dhcp4"],
        arguments: {subnets: [subnet_kea_id]}
      }.to_json

      parse_response(http.request(req).body).fetch("leases")
    end

    def fetch_stats
      req = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
      req.body = {
        command: "statistic-get-all",
        service: ["dhcp4"]
      }.to_json

      http.request(req).body
    end

    private

    def http
      @http ||= Net::HTTP.new(uri.host, uri.port)
    end

    def uri
      URI(ENV.fetch("KEA_CONTROL_AGENT_URI"))
    end

    def parse_response(response_body)
      JSON.parse(response_body).first.fetch("arguments")
    end
  end
end
