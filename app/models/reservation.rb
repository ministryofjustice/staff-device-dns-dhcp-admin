class Reservation < ApplicationRecord
  belongs_to :subnet

  validate :ip_address_is_a_valid_ipv4_address

  private

  def ip_address_is_a_valid_ipv4_address
    return if ip_address.blank?

    unless IPAddress.valid_ipv4?(ip_address)
      errors.add(:ip_address, "is not a valid IPv4 address")
    end
  end
end
