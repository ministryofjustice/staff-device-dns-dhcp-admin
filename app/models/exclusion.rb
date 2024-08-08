class Exclusion < ApplicationRecord
  belongs_to :subnet

  validates :subnet, presence: true
  validates :start_address, presence: true
  validates :end_address, presence: true

  validate :start_address_is_a_valid_ipv4_address
  validate :end_address_is_a_valid_ipv4_address
  validate :start_address_is_before_end_address
  validate :start_address_is_within_the_subnet
  validate :end_address_is_within_the_subnet

  audited

  def start_address_ip_addr
    IPAddr.new(start_address)
  end

  def end_address_ip_addr
    IPAddr.new(end_address)
  end

  def total_addresses
    # TODO: Should this include x.x.x.0 if the mask overlaps
    # subnets larger than /24?
    (start_address_ip_addr..end_address_ip_addr).to_a.length
  end

  def contains_ip_address?(ip_address)
    (start_address_ip_addr..end_address_ip_addr).to_a.include?(ip_address)
  end

  private

  def start_address_is_a_valid_ipv4_address
    return if start_address.blank?

    unless IPAddress.valid_ipv4?(start_address)
      errors.add(:start_address, "is not a valid IPv4 address")
    end
  end

  def end_address_is_a_valid_ipv4_address
    return if end_address.blank?

    unless IPAddress.valid_ipv4?(end_address)
      errors.add(:end_address, "is not a valid IPv4 address")
    end
  end

  def start_address_is_before_end_address
    return if start_address.blank? || end_address.blank?
    return unless IPAddress.valid_ipv4?(start_address) && IPAddress.valid_ipv4?(end_address)

    unless IPAddr.new(start_address) < IPAddr.new(end_address)
      errors.add(:end_address, "must be after the start address")
    end
  end

  def start_address_is_within_the_subnet
    return if subnet.blank?
    return if start_address.blank? || end_address.blank?
    return unless IPAddress.valid_ipv4?(start_address)

    unless IPAddr.new(start_address) >= IPAddr.new(subnet.start_address) && IPAddr.new(start_address) <= IPAddr.new(subnet.end_address)
      errors.add(:start_address, "is outside subnet range")
    end
  end

  def end_address_is_within_the_subnet
    return if subnet.blank?
    return if start_address.blank? || end_address.blank?
    return unless IPAddress.valid_ipv4?(end_address)

    unless IPAddr.new(end_address) >= IPAddr.new(subnet.start_address) && IPAddr.new(end_address) <= IPAddr.new(subnet.end_address)
      errors.add(:end_address, "is outside subnet range")
    end
  end
end
