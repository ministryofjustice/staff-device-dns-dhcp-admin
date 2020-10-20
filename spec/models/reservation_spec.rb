require "rails_helper"

RSpec.describe Reservation, type: :model do
  it "validates a correct ip address" do
    reservation = build :reservation, ip_address: "10.0.4.1"
    expect(reservation).to be_valid
  end

  it "validates an incorrect ip address" do
    reservation = build :reservation, ip_address: "10.0.4"
    expect(reservation).not_to be_valid
    expect(reservation.errors[:ip_address]).to eq(["is not a valid IPv4 address"])
  end
end
