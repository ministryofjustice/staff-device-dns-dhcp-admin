class Reservation < ApplicationRecord
  MAC_ADDRESS_REGEX = /\A([0-9a-fA-F][0-9a-fA-F]:){5}([0-9a-fA-F][0-9a-fA-F])\z/

  belongs_to :subnet
  has_one :reservation_option, dependent: :destroy

  validates :ip_address, presence: true
  validates :hostname, host_name: true, presence: true
  validates :hw_address, format: {with: MAC_ADDRESS_REGEX, message: "%{value} must be in the form 1a:1b:1c:1d:1e:1f"}, presence: true

  validate :ip_address_is_a_valid_ipv4_address
  validate :ip_address_is_within_the_subnet

  validate :hw_address_is_unique_within_subnet
  validate :hostname_is_unique_within_subnet
  validate :ip_address_is_unique_within_subnet

  audited

  delegate :ip_addr, :start_address_ip_addr, :end_address_ip_addr, to: :subnet, prefix: true

  scope :for_subnet, ->(subnet_id) do
    where(subnet_id: subnet_id)
  end

  scope :for_subnet_and_hw_address, ->(subnet_id, hw_address) do
    for_subnet(subnet_id).where(hw_address: hw_address)
  end

  scope :for_subnet_and_ip_address, ->(subnet_id, ip_address) do
    for_subnet(subnet_id).where(ip_address: ip_address)
  end

  scope :for_subnet_and_hostname, ->(subnet_id, hostname) do
    for_subnet(subnet_id).where(hostname: hostname)
  end

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
      errors.add(:ip_address, "#{ip_address} is not a valid IPv4 address")
    end
  end

  def ip_address_is_within_the_subnet
    return if ip_address.blank?
    return unless IPAddress.valid_ipv4?(ip_address)

    if !subnet_ip_addr.include?(ip_addr) ||
        (ip_addr < subnet_start_address_ip_addr || ip_addr > subnet_end_address_ip_addr)
      errors.add(:ip_address, "#{ip_address} is not within the subnet range #{subnet_start_address_ip_addr} - #{subnet_end_address_ip_addr}")
    end
  end

  def hw_address_is_unique_within_subnet
    if Reservation.for_subnet_and_hw_address(subnet_id, hw_address).where.not(id: id).exists?
      errors.add(:hw_address, "#{hw_address} has already been reserved in the subnet #{subnet.cidr_block}")
    end
  end

  def ip_address_is_unique_within_subnet
    if Reservation.for_subnet_and_ip_address(subnet_id, ip_address).where.not(id: id).exists?
      errors.add(:ip_address, "#{ip_address} has already been reserved in the subnet #{subnet.cidr_block}")
    end
  end

  def hostname_is_unique_within_subnet
    if Reservation.for_subnet_and_hostname(subnet_id, hostname).where.not(id: id).exists?
      errors.add(:hostname, "#{hostname} has already been reserved in the subnet #{subnet.cidr_block}")
    end
  end

  def hostname_is_valid
    unless HOSTNAME_REGEX.match?(:hostname)
      errors.add(:hostname, "is not valid")
    end
  end

end
