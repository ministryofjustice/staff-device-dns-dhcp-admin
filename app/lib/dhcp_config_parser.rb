require "json"

class DhcpConfigParser
  include MacAddressHelper

  # Integration test for the class with expectation to have reservations created when they are missing on the kea config

  # dhcp_config_parser_spec calls .run which has no arguments, i.e. the entire method is called
  # this means that KEA_CONFIG_FILEPATH, is called which is a statically defined file.

  # refactor run to create more flexibility

  def initialize(kea_config_filepath:, legacy_config_filepath:)
    @kea_config_filepath = kea_config_filepath
    @legacy_config_filepath = legacy_config_filepath
  end

  def run(fits_id:, subnet_list:)
    throw StandardError unless kea_config_exists?
    throw StandardError unless export_file_exists?

    # Populate these with data from the portal/export before running.
    # See readme if you're feeling ¯\_(ツ)_/¯
    shared_network_id = fits_id

    exclusion_data = get_legacy_exclusions(File.read(@legacy_config_filepath), subnet_list)

    compared_reservations = find_missing_reservations(
      kea_reservations: get_kea_reservations(shared_network_id, File.read(@kea_config_filepath)),
      legacy_reservations: get_legacy_reservations(File.read(@legacy_config_filepath), subnet_list)
    )

    create_reservations(
      reservations_by_subnet(compared_reservations)
    )

    compared_reservations
  end

  def reservations_by_subnet(compared_reservations)
    compared_reservations.group_by do |reservation|
      reservation["legacy"]["ip-address"].gsub(/(\d{1,3})$/, "")
    end
  end

  def create_reservations(reservations_by_subnet)
    reservations_by_subnet.each do |subnet, reservations|
      subnet = Subnet.where("cidr_block LIKE ?", "#{subnet}%").first
      reservations.each do |reservation|
        Reservation.create!(
          subnet: subnet,
          hw_address: format_mac_address(reservation["legacy"]["hw-address"]),
          ip_address: reservation["legacy"]["ip-address"],
          hostname: reservation["legacy"]["hostname"].gsub(/\.$/, "")
        )
      end
    end
  end

  def kea_config_exists?
    File.exist?(@kea_config_filepath)
  end

  def export_file_exists?
    File.exist?(@legacy_config_filepath)
  end

  def get_legacy_exclusions(export, subnet_list)
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

  def get_kea_reservations(shared_network_id, kea_config)
    kea_config_hash = JSON.parse(kea_config)
    shared_networks = kea_config_hash["Dhcp4"]["shared-networks"].select { |shared_network| shared_network["name"].include?(shared_network_id) }

    reservations = shared_networks.inject([]) do |accumulator, shared_network|
      shared_network["subnet4"].each do |subnet|
        accumulator += subnet["reservations"] if subnet["reservations"]
      end

      accumulator
    end
  end

  def get_legacy_reservations(export, subnet_list)
    reservation_fields = ["ip-address", "hw-address", "hostname"]
    legacy_reservations = []

    subnet_list.each do |subnet|
      ip_mac_hostname_regex = /#{subnet.chop}\d{1,3}.(?:[a-fA-F0-9]{12})."[^"]*"."[^"]*"/
      reservations_data = export.scan(ip_mac_hostname_regex)
      reservations_data.each do |reservation|
        reservations = reservation.tr('"', "").split(" ")
        legacy_reservations.push(reservations)
      end
    end

    legacy_reservations.map { |row| reservation_fields.zip(row).to_h }
  end

  def find_missing_reservations(kea_reservations:, legacy_reservations:)
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
