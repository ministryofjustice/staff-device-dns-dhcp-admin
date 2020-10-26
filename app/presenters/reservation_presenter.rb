class ReservationPresenter < BasePresenter
  def display_name
    record.hw_address
  end
end
