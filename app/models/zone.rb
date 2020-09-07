class Zone < ApplicationRecord
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :forwarders, presence: true

  validate :forwarders_is_a_valid_bind_dns_forwarder

  def forwarders_is_a_valid_bind_dns_forwarder
    return if forwarders.blank?

    unless forwarders.end_with?(";")
      errors.add(:forwarders, "must end with a semi-colon")
    end

    ip_addresses = forwarders.split(";")

    if ip_addresses.none? || ip_addresses.any? { |ip_address| !IPAddress.valid_ipv4?(ip_address) }
      errors.add(:forwarders, "contains an invalid IPv4 address")
    end
  end
end
