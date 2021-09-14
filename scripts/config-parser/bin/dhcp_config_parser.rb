#!/bin/ruby

require_relative "../lib/dhcp_config_parser"

puts "There are #{DhcpConfigParser.run.length} differences in reservation data"
puts "Take a look at ./data/reservation_diff.json for a breakdown"

reservation_diff = File.open("./data/reservation_diff.json", "w")

reservation_diff << DhcpConfigParser.run.to_json
reservation_diff.close
