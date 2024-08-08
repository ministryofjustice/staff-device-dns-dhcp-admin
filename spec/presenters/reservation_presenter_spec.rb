require "rails_helper"

describe ReservationPresenter do
  describe "#display_name" do
    it "returns the reservation hw_address" do
      reservation = build_stubbed(:reservation)
      presenter = ReservationPresenter.new(reservation)

      expect(presenter.display_name).to eq(reservation.hw_address)
    end

    it "formats reservation hw_address" do
      reservation = build_stubbed(:reservation)
      reservation.hw_address = "01-bb-cc-dd-ee-ff"
      presenter = ReservationPresenter.new(reservation)

      expect(presenter.display_name).not_to eq(reservation.hw_address)
      expect(presenter.display_name).to eq("01:bb:cc:dd:ee:ff")
    end
  end
end
