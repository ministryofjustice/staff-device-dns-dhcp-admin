require "json"

class DhcpConfigParser

  def self.kea_config_exists?

    if !File.exist?("kea.json")
      false
    elsif File.exist?("kea.json")
      true

    end  
  end

  def self.export_file_exists?
    if !File.exist?("export.txt")
      false
    elsif File.exist?("export.txt")
      true
    end
  end

  def self.get_kea_reservations(shared_network_id,kea_config)
    
    kea_config_hash = JSON.parse(kea_config)
    shared_networks = kea_config_hash["Dhcp4"]["shared-networks"].select { |shared_network| shared_network["name"].include?(shared_network_id) }

    reservations = shared_networks.inject([]) do |accumulator, shared_network|
      shared_network["subnet4"].each do |subnet|
        # accumulator += (subnet["reservations"] || [])
        accumulator += subnet["reservations"] if subnet["reservations"]
      end
    
      accumulator
    end

  end

  def self.get_legacy_reservations(export, subnet_list)
      
    reservation_fields = ["ip-address", "hw-address", "hostname"]
    legacy_reservations = []

    subnet_list.each do |subnet|
      export.scan(/#{subnet.chop}\d{1,3}.(?:[a-fA-F0-9]{12})."[^"]*"."[^"]*"/)
            .each do |reservation|
        reservations = reservation.delete!('"').split(" ")
        legacy_reservations.push(reservations)
      end
    end
    
    legacy_reservations.map { |row| reservation_fields.zip(row).to_h }

  end
end

# 1. brittle / not flexible 
# 2. Duplication 
