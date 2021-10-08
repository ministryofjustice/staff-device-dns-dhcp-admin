#!/bin/ruby

require_relative "../lib/dhcp_config_parser"

parsed_config = DhcpConfigParser.new(kea_config_filepath: "./data/kea.json").run

puts "There are #{parsed_config.length} differences in reservation data"
puts "Take a look at ./data/reservation_diff.json for a breakdown"

reservation_diff = File.open("./data/reservation_diff.json", "w")

reservation_diff << parsed_config.to_json
reservation_diff.close
