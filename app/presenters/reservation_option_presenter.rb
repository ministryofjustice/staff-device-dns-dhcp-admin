class ReservationOptionPresenter < BasePresenter
  include MacAddressHelper

  delegate :reservation, to: :record

  def display_name
    format_mac_address(reservation.hw_address)
  end
end
