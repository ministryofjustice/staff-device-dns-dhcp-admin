class Option < ApplicationRecord
  validates :routers, presence: true
  validates :domain_name_servers, presence: true
  validates :domain_name, presence: true

  validate :routers_is_a_valid
  validate :domain_name_servers_is_valid

  def routers_is_a_valid
    return if routers.blank?
    validate_ip_addresses(:routers, routers)
  end

  def domain_name_servers_is_valid
    return if domain_name_servers.blank?
    validate_ip_addresses(:domain_name_servers, domain_name_servers)
  end

  private 

  def all_ips_valid?(ip_addresses_string)
    ip_addresses = ip_addresses_string.split(",")
    ip_addresses.all? { |ip_address| IPAddress.valid_ipv4?(ip_address) }
  end

  def validate_ip_addresses(attribute_name, ip_addresses_string)
    return if all_ips_valid?(ip_addresses_string)
    errors.add(attribute_name, "contains an invalid IPv4 address")
  end
end
