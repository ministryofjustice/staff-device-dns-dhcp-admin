require "ipaddr"
require "faker"

def random_mac
  6.times.map { "%02x" % rand(0..255) }.join(":")
end

# def end_range(range)
#   range_array = range.to_s.split(".")
#   last_char = range_array.last.to_i + 24
#   range_array[0].to_s + "." + range_array[1].to_s + "." + range_array[2].to_s + "." + last_char.to_s
# end

# def ip_range(subnet_count, count)
#   "#{count + 10}.0.0.#{subnet_count}"
# end

def range(site_index, subnet_index)
  "#{site_index + 10}.0.#{subnet_index + 1}.0"
end

def start_address(range)
  range_array = range.to_s.split(".")
  last_char = range_array.last.to_i + 1
  range_array[0].to_s + "." + range_array[1].to_s + "." + range_array[2].to_s + "." + last_char.to_s
end

def end_address(range)
  range_array = range.to_s.split(".")
  last_char = range_array.last.to_i + 254
  range_array[0].to_s + "." + range_array[1].to_s + "." + range_array[2].to_s + "." + last_char.to_s
end

def reserved_address(range, reservation_index)
  range_array = range.to_s.split(".")
  last_char = range_array.last.to_i + reservation_index + 1
  range_array[0].to_s + "." + range_array[1].to_s + "." + range_array[2].to_s + "." + last_char.to_s
end

def main
  150.times do |count|
    site = Site.create!(name: "Site #{count}", fits_id: "FITS_#{count}")
    shared_network = SharedNetwork.create!(site: site)
    5.times do |subnet_count|
      range = range(count, subnet_count)
      subnet = Subnet.create!(cidr_block: "#{range}/24", start_address: start_address(range), end_address: end_address(range), routers: start_address(range), shared_network: shared_network)
      rand(5..20).times.with_index(0) do |random_number, index|
        subnet.reservations.create!(ip_address: reserved_address(range, index).to_s, hostname: "#{Faker::Internet.domain_word}-#{index}", hw_address: Faker::Internet.mac_address)
      end
      subnet.exclusions.create!(start_address: start_address(range), end_address: end_address(range))
      p end_address(range)
    end
  end
end

def clear
  Site.destroy_all
  SharedNetwork.destroy_all
  Subnet.destroy_all
  Reservation.destroy_all
  Exclusion.destroy_all
end

clear
main