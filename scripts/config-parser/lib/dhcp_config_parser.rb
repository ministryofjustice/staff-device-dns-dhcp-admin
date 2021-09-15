require "json"

class DhcpConfigParser
  KEA_CONFIG_FILEPATH = "./data/kea.json".freeze
  LEGACY_CONFIG_FILEPATH = "./data/export.txt".freeze

  def self.run
    throw StandardError unless kea_config_exists?
    throw StandardError unless export_file_exists?

    # Populate these with data from the portal/export before running.
    # See readme if you're feeling ¯\_(ツ)_/¯
    shared_network_id = "FITS_####"
    subnet_list = ["192.168.1.0", "192.168.2.0", "192.168.3.0"]

    exclusion_data = get_legacy_exclusions(File.read(LEGACY_CONFIG_FILEPATH), subnet_list)

    puts "This site has the following #{exclusion_data.length} exclusions configured :"
    puts exclusion_data
    puts "----"

    compared_reservations = find_missing_reservations(
      kea_reservations: get_kea_reservations(shared_network_id, File.read(KEA_CONFIG_FILEPATH)),
      legacy_reservations: get_legacy_reservations(File.read(LEGACY_CONFIG_FILEPATH), subnet_list)
    )
  end

  def self.kea_config_exists?
    File.exist?(KEA_CONFIG_FILEPATH)
  end

  def self.export_file_exists?
    File.exist?(LEGACY_CONFIG_FILEPATH)
  end

  def self.get_legacy_exclusions(export, subnet_list)
    exclusion_fields = ["type", "start-ip", "end-ip"]
    legacy_exclusions = []

    subnet_list.each do |subnet|
      exclusion_regex = /excluderange.#{subnet.chop}\d{1,3}.#{subnet.chop}\d{1,3}/
      export.scan(exclusion_regex)
        .each do |exclusion|
        exclusions = exclusion.split(" ")
        legacy_exclusions.push(exclusions)
      end
    end

    legacy_exclusions.map { |row| exclusion_fields.zip(row).to_h }
  end

  def self.get_kea_reservations(shared_network_id, kea_config)
    kea_config_hash = JSON.parse(kea_config)
    shared_networks = kea_config_hash["Dhcp4"]["shared-networks"].select { |shared_network| shared_network["name"].include?(shared_network_id) }

    reservations = shared_networks.inject([]) do |accumulator, shared_network|
      shared_network["subnet4"].each do |subnet|
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
        reservations = reservation.tr('"', "").split(" ")
        legacy_reservations.push(reservations)
      end
    end

    legacy_reservations.map { |row| reservation_fields.zip(row).to_h }
  end

  def self.find_missing_reservations(kea_reservations:, legacy_reservations:)
    grouped_kea_reservations = kea_reservations.group_by { |res| res["hw-address"].downcase.tr(":", "") }
    grouped_legacy_reservations = legacy_reservations.group_by { |res| res["hw-address"].downcase.tr(":", "") }

    reservations = {}

    grouped_kea_reservations.each do |hw_address, grouped_kea_reservations|
      reservations[hw_address] ||= {"hw-address" => hw_address, "kea" => nil, "legacy" => nil}
      reservations[hw_address]["kea"] = grouped_kea_reservations.first
    end

    grouped_legacy_reservations.each do |hw_address, grouped_legacy_reservations|
      reservations[hw_address] ||= {"hw-address" => hw_address, "kea" => nil, "legacy" => nil}
      reservations[hw_address]["legacy"] = grouped_legacy_reservations.first
    end

    reservations.values.reject do |reservation|
      reservation["kea"] && reservation["legacy"]
      # place to look into return IP == IP
    end
  end
end
