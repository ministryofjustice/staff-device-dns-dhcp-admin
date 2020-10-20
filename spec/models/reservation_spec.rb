require "rails_helper"

RSpec.describe Reservation, type: :model do
  subject { build :reservation }

  context "hostname validation" do
    it { should allow_value("example.com").for(:hostname) }
    it { should allow_value("foo.example.com").for(:hostname) }
    it { should allow_value("foo-bar-1.abc.123.example.com").for(:hostname) }
    it { should allow_value("foo-BAR-1.ABC.123.example.com").for(:hostname) }
    it { should_not allow_value("i_contain_an_at_sign@gov.uk").for(:hostname) }
    it { should_not allow_value("测试.com").for(:hostname) }
  end

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
