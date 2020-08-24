require "rails_helper"

RSpec.describe Subnet, type: :model do
  it { is_expected.to validate_presence_of :cidr_block }
  it { is_expected.to validate_presence_of :start_address }
  it { is_expected.to validate_presence_of :end_address }

  it "validates a correct CIDR block" do
    subnet = build :subnet, cidr_block: "10.0.4.0/24"
    expect(subnet).to be_valid
  end

  it "validates an incorrect CIDR block" do
    subnet = build :subnet, cidr_block: "10.0.4.0/abcd"
    expect(subnet).not_to be_valid
    expect(subnet.errors[:cidr_block]).to eq(["is not a valid IPv4 subnet"])
  end

  it "validates a correct start address" do
    subnet = build :subnet, start_address: "10.0.4.1"
    expect(subnet).to be_valid
  end

  it "validates an incorrect start address" do
    subnet = build :subnet, start_address: "10.0.4"
    expect(subnet).not_to be_valid
    expect(subnet.errors[:start_address]).to eq(["is not a valid IPv4 address"])
  end

  it "validates a correct end address" do
    subnet = build :subnet, end_address: "10.0.4.1"
    expect(subnet).to be_valid
  end

  it "validates an incorrect end address" do
    subnet = build :subnet, end_address: "10.0.4"
    expect(subnet).not_to be_valid
    expect(subnet.errors[:end_address]).to eq(["is not a valid IPv4 address"])
  end
end
