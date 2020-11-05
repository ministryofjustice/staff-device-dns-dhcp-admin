require "net/http"
require "json"

module Gateways
  class KeaControlAgent
    def fetch_leases
      uri = URI(ENV.fetch("KEA_CONTROL_AGENT_URI"))
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
      req.body = {
        command: "lease4-get-all",
        service: ["dhcp4"]
      }.to_json

      http.request(req).body
    end
  end
end
