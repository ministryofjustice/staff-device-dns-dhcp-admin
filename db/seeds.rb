require "faker"
require "ipaddr"

SITE_COUNT = 150
SUBNET_COUNT = 5

def range(site_index, subnet_index)
  IPAddr.new("172.#{site_index + 1}.#{subnet_index + 1}.0/24")
end

def start_address(range)
  range.to_range.to_a[1].to_s
end

def end_address(range)
  range.to_range.to_a[254].to_s
end

def exclusion_start_address(range)
  range.to_range.to_a[rand(30..40)]
end

def exclusion_end_address(range)
  range.to_range.to_a[rand(80..90)]
end

def reserved_address(range, reservation_index)
  range.to_range.to_a[reservation_index + 1]
end

def create_site(count)
  p "Creating site: ##{count + 1}"
  Site.create!(name: "Site #{count + 1}", fits_id: "FITS_#{count + 1}")
end

def create_shared_network(site)
  SharedNetwork.create!(site: site)
end

def create_subnet(range, shared_network)
  p "Creating subnet: #{range}/24"
  Subnet.create!(
    cidr_block: "#{range}/24".to_s,
    start_address: start_address(range),
    end_address: end_address(range),
    routers: start_address(range),
    shared_network: shared_network
  )
end

def create_reservations(subnet, range)
  rand(5..20).times do |count|
    subnet.reservations.create!(
      ip_address: reserved_address(range, count).to_s,
      hostname: "#{Faker::Internet.domain_word}-#{count}",
      hw_address: Faker::Internet.mac_address
    )
  end
end

def create_exclusions(subnet, range)
  subnet.exclusions.create!(
    start_address: exclusion_start_address(range),
    end_address: exclusion_end_address(range)
  )
end

def main
  SITE_COUNT.times do |count|
    site = create_site(count)
    shared_network = create_shared_network(site)

    SUBNET_COUNT.times do |subnet_count|
      range = range(count, subnet_count)
      subnet = create_subnet(range, shared_network)

      create_reservations(subnet, range)
      create_exclusions(subnet, range)
    end
  end
end

main
