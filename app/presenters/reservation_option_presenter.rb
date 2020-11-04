class ReservationOptionPresenter < BasePresenter
  delegate :reservation, to: :record

  def display_name
    reservation.hw_address
  end
end
