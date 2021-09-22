require 'rails_helper'

describe MacAddressHelper do
  context 'returns a correctly formatted MAC address when' do
    it 'given a correctly formatted MAC address' do
      mac_address = '01:bb:cc:dd:ee:ff'

      expect(helper.format_mac_address(mac_address)).to eq('01:bb:cc:dd:ee:ff')
    end

    it 'given a MAC address with "-" delimiter' do
      mac_address = '01-bb-cc-dd-ee-ff'

      expect(helper.format_mac_address(mac_address)).to eq('01:bb:cc:dd:ee:ff')
    end

    it 'given a MAC address without a delimiter' do
      mac_address = '01bbccddeeff'

      expect(helper.format_mac_address(mac_address)).to eq('01:bb:cc:dd:ee:ff')
    end

    it 'given a MAC address with space delimiter' do
      mac_address = '01 bb cc dd ee ff'

      expect(helper.format_mac_address(mac_address)).to eq('01:bb:cc:dd:ee:ff')
    end
  end

  context 'when given a incorrect MAC address' do
    it 'returns the raw value when it is too short' do
      mac_address = '01:bb:cc:dd:ee'

      expect(helper.format_mac_address(mac_address)).to eq('01:bb:cc:dd:ee')
    end

    it 'returns the raw value when it is too long' do
      mac_address = '01:bb:cc:dd:ee:ff:aa'

      expect(helper.format_mac_address(mac_address)).to eq('01:bb:cc:dd:ee:ff:aa')
    end

    it 'returns the raw value when it contains illegal chars' do
      mac_address = '01-bb-cc-dd-ee-XX'

      expect(helper.format_mac_address(mac_address)).to eq('01-bb-cc-dd-ee-XX')
    end
  end
end
