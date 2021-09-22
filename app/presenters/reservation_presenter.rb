class ReservationPresenter < BasePresenter
  include MacAddressHelper

  def display_name
    format_mac_address(record.hw_address)
  end
end
