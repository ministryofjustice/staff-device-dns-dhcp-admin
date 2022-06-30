require "faker"
require "ipaddr"

SITE_COUNT = 15
SUBNET_COUNT = 5

def range(site_index, subnet_index)
  IPAddr.new("#{site_index + 10}.0.#{subnet_index + 1}.0")
end

def start_address(range)
  p "start address"
  range.to_range.to_a[1].to_s
end

def end_address(range)
  p "end address"
  range.to_range.to_a[254].to_s
end

def exclusion_start_address(range)
  p "exclusion start"
  range.to_range.to_a[rand(80..90)]
end

def exclusion_end_address(range)
  p "exclusion end"
  range.to_range.to_a[rand(80..90)]
end

def reserved_address(range, reservation_index)
  range_array = range.to_s.split(".")
  last_char = range_array.last.to_i + reservation_index + 1
  range_array[0].to_s + "." + range_array[1].to_s + "." + range_array[2].to_s + "." + last_char.to_s
end

def clear
  Site.destroy_all
  SharedNetwork.destroy_all
  Subnet.destroy_all
  Reservation.destroy_all
  Exclusion.destroy_all
end

def create_site(count)
  Site.create!(name: "Site #{count}", fits_id: "FITS_#{count}")
end

def create_shared_network(site)
  SharedNetwork.create!(site: site)
end

def create_subnet(range, shared_network)
  Subnet.create!(
    cidr_block: "#{range}/24",
    start_address: start_address(range),
    end_address: end_address(range),
    routers: start_address(range),
    shared_network: shared_network
  )
end

def create_subnet_reservations(subnet, range)
  rand(5..20).times do |count|
    subnet.reservations.create!(
      ip_address: reserved_address(range, count).to_s,
      hostname: "#{Faker::Internet.domain_word}-#{count}",
      hw_address: Faker::Internet.mac_address
    )
  end
end

def create_subnet_exclusions(subnet, range)
  subnet.exclusions.create!(
    start_address: exclusion_start_address(range),
    end_address: exclusion_end_address(range)
  )
end

def main
  p "we are starting"

  SITE_COUNT.times do |count|
    site = create_site(count)
    shared_network = create_shared_network(site)

    SUBNET_COUNT.times do |subnet_count|
      range = range(count, subnet_count)
      p range
      subnet = create_subnet(range, shared_network)

      create_subnet_reservations(subnet, range)
      create_subnet_exclusions(subnet, range)
    end
  end
end

clear
main
