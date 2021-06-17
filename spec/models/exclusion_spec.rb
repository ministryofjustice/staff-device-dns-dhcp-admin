require "rails_helper"

RSpec.describe Exclusion, type: :model do
  subject { build :exclusion }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :subnet }

  it { is_expected.to validate_presence_of :start_address }
  it { is_expected.to validate_presence_of :end_address }

  it "validates an incorrect start address" do
    exclusion = build :exclusion, start_address: "10.0.4", end_address: "10.0.4.20"
    expect(exclusion).not_to be_valid
    expect(exclusion.errors[:start_address]).to eq(["is not a valid IPv4 address"])
  end

  it "validates an incorrect end address" do
    exclusion = build :exclusion, start_address: "10.0.4.10", end_address: "10.0.4"
    expect(exclusion).not_to be_valid
    expect(exclusion.errors[:end_address]).to eq(["is not a valid IPv4 address"])
  end

  it "is invalid if start address is after end address" do
    exclusion = build :exclusion, start_address: "10.0.4.40", end_address: "10.0.4.20"
    expect(exclusion).not_to be_valid
  end

  it "is invalid if the start_address is outside the subnet start and end address" do
    subnet = create(:subnet, cidr_block: "10.0.4.0/24", start_address: "10.0.4.10", end_address: "10.0.4.100")
    exclusion = build :exclusion, subnet: subnet, start_address: "10.0.4.5", end_address: "10.0.4.50"
    expect(exclusion).not_to be_valid
  end

  it "is invalid if the end_address is outside the subnet start and end address" do
    subnet = create(:subnet, cidr_block: "10.0.4.0/24", start_address: "10.0.4.10", end_address: "10.0.4.100")
    exclusion = build :exclusion, subnet: subnet, start_address: "10.0.4.20", end_address: "10.0.4.150"
    expect(exclusion).not_to be_valid
  end
  
end
