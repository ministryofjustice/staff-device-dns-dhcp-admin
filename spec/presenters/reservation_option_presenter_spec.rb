require "rails_helper"

describe ReservationOptionPresenter do
  describe "#display_name" do
    it "returns the reservation hw_address" do
      reservation_option = build_stubbed(:reservation_option)
      presenter = ReservationOptionPresenter.new(reservation_option)

      expect(presenter.display_name).to eq(reservation_option.reservation.hw_address)
    end

    it "formats reservation hw_address" do
      reservation_option = build_stubbed(:reservation_option)
      reservation_option.reservation.hw_address = "01-bb-cc-dd-ee-ff"
      presenter = ReservationOptionPresenter.new(reservation_option)

      expect(presenter.display_name).not_to eq(reservation_option.reservation.hw_address)
      expect(presenter.display_name).to eq("01:bb:cc:dd:ee:ff")
    end
  end
end
