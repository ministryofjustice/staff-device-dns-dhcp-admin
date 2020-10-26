class Reservation < ApplicationRecord
  MAC_ADDRESS_REGEX = /\A([0-9a-fA-F][0-9a-fA-F]:){5}([0-9a-fA-F][0-9a-fA-F])\z/

  belongs_to :subnet

  validates :ip_address, presence: true
  validates :hostname, domain_name: true
  validates :hw_address, format: {with: MAC_ADDRESS_REGEX, message: "must be in the form 1a:1b:1c:1d:1e:1f"}, presence: true

  validate :ip_address_is_a_valid_ipv4_address
  validate :ip_address_is_within_the_subnet

  validate :hw_address_is_unique_within_subnet
  validate :hostname_is_unique_within_subnet

  audited

  delegate :ip_addr, :start_address_ip_addr, :end_address_ip_addr, to: :subnet, prefix: true

  def ip_addr
    IPAddr.new(ip_address)
  end

  def hw_address=(val)
    self[:hw_address] = val.try(:strip)
  end

  def ip_address=(val)
    self[:ip_address] = val.try(:strip)
  end

  def hostname=(val)
    self[:hostname] = val.try(:strip)
  end

  private

  def ip_address_is_a_valid_ipv4_address
    return if ip_address.blank?

    unless IPAddress.valid_ipv4?(ip_address)
      errors.add(:ip_address, "is not a valid IPv4 address")
    end
  end

  def ip_address_is_within_the_subnet
    return if ip_address.blank?
    return unless IPAddress.valid_ipv4?(ip_address)

    if !subnet_ip_addr.include?(ip_addr) ||
        (ip_addr < subnet_start_address_ip_addr || ip_addr > subnet_end_address_ip_addr)
      errors.add(:ip_address, "is not within the subnet range")
    end
  end

  def hw_address_is_unique_within_subnet
    return if hw_address.blank?

    Reservation.where(subnet_id: subnet_id).each do |reservation|
      if reservation.id != id
        if reservation.hw_address == hw_address
          errors.add(:hw_address, "has already been reserved in the subnet")
          return false
        end
      end
    end

    true
  end

  def ip_address_is_unique_within_subnet
    return if ip_address.blank?

    Reservation.where(subnet_id: subnet_id).each do |reservation|
      if reservation.id != id
        if reservation.ip_address == ip_address
          errors.add(:ip_address, "has already been reserved in the subnet")
          return false
        end
      end
    end

    true
  end

  def hostname_is_unique_within_subnet
    return if hostname.blank?

    Reservation.where(subnet_id: subnet_id).each do |reservation|
      if reservation.id != id
        if reservation.hostname == hostname
          errors.add(:hostname, "has already been reserved in the subnet")
          return false
        end
      end
    end

    true
  end
end
