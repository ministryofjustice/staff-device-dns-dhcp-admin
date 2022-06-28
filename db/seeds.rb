require "ipaddr"

def random_mac
  6.times.map { "%02x" % rand(0..255) }.join(":")
end

def end_range(range)
  range_array = range.to_s.split(".")
  last_char = range_array.last.to_i + 1
  range_array[0].to_s + "." + range_array[1].to_s + "." + range_array[2].to_s + "." + last_char.to_s
end

def ip_range(subnet_count, count)
  "#{count + 10}.0.0.#{subnet_count}"
end

def main
  100.times do |count|
    site = Site.create!(name: "Site #{count}", fits_id: "FITS_#{count}")
    shared_network = SharedNetwork.create!(site: site)
    5.times do |subnet_count|
      range = ip_range(subnet_count, count)
      subnet = Subnet.create!(cidr_block: "#{range}/24", start_address: range, end_address: end_range(range), routers: range.split("/").first, shared_network: shared_network)
      subnet.reservations.create!(ip_address: range.to_s, hostname: "host-#{count}", hw_address: random_mac)
      p end_range(range)
      subnet.exclusions.create!(start_address: range.to_s, end_address: end_range(range))
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
