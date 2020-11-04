require "rails_helper"

describe ReservationOptionPresenter do
  describe "#display_name" do
    it "returns the reservation hw_address" do
      reservation_option = build_stubbed(:reservation_option)
      presenter = ReservationOptionPresenter.new(reservation_option)

      expect(presenter.display_name).to eq(reservation_option.reservation.hw_address)
    end
  end
end
