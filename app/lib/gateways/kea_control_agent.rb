require "net/http"
require "json"

module Gateways
  class KeaControlAgent
    def initialize(uri:)
      @uri = URI(uri)
    end

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

    attr_reader :uri

    def http
      @http ||= Net::HTTP.new(uri.host, uri.port)
    end


    def parse_response(response_body)
      JSON.parse(response_body).first.fetch("arguments")
    end
  end
end
