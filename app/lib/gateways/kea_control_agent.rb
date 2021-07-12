require "net/http"
require "json"

module Gateways
  class KeaControlAgent
    def initialize(uri:, logger: nil)
      @uri = URI(uri)
      @logger = logger
    end

    def fetch_leases(subnet_kea_id)
      req = Net::HTTP::Post.new(uri.path, headers)
      req.body = {
        command: "lease4-get-all",
        service: ["dhcp4"],
        arguments: {subnets: [subnet_kea_id]}
      }.to_json

      handle_response(http.request(req).body).dig("arguments").fetch("leases")
    end

    def fetch_lease(lease_ip_address)
      req = Net::HTTP::Post.new(uri.path, headers)
      req.body = {
        command: "lease4-get",
        service: ["dhcp4"],
        arguments: {
          "ip-address" => lease_ip_address
      }
      }.to_json

      handle_response(http.request(req).body).dig("arguments")
    end

    def verify_config(config)
      req = Net::HTTP::Post.new(uri.path, headers)
      req.body = {
        command: "config-test",
        service: ["dhcp4"],
        arguments: config
      }.to_json

      handle_response(http.request(req).body)
    end

    private

    attr_reader :uri, :logger

    def headers
      {
        "Content-Type" => "application/json"
      }
    end

    def http
      @http ||= Net::HTTP.new(uri.host, uri.port)
    end

    def parse_response(response_body)
      JSON.parse(response_body).first
    end

    def handle_response(response_body)
      logger&.info("Kea response: #{response_body}")

      body = parse_response(response_body)

      case body.fetch("result")
      when 1
        raise InternalError.new(body.fetch("text"))
      when 2
        raise InvalidCommand.new("The command is not implemented by the Kea Control Agent")
      else
        body
      end
    end

    class InternalError < StandardError; end

    class InvalidCommand < StandardError; end
  end
end
