module MacAddressHelper
  MAC_ADDRESS_LENGTH = 12
  DELIMITER_LIST = '\\s:-'.freeze

  def format_mac_address(original_mac_address)
    return original_mac_address if valid_mac_address?(original_mac_address)

    stripped_mac_address = original_mac_address.gsub(/[#{DELIMITER_LIST}]/, '')

    return original_mac_address unless valid_mac_address_char_length?(stripped_mac_address)

    final_formatted_mac_address = stripped_mac_address.scan(/.{1,2}/m).join(':')

    return original_mac_address unless valid_mac_address?(final_formatted_mac_address)

    final_formatted_mac_address
  end

  private

  def valid_mac_address?(mac_address)
    Reservation::MAC_ADDRESS_REGEX =~ mac_address
  end

  def valid_mac_address_char_length?(mac_address)
    mac_address.length == MAC_ADDRESS_LENGTH
  end
end
