#!/bin/ruby

require_relative "../lib/dhcp_config_parser"

reservation_diff = File.open("./data/reservation_diff.json", "w")

reservation_diff <<
  DhcpConfigParser.run.to_json
reservation_diff.close
