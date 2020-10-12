require "rails_helper"

RSpec.describe Zone, type: :model do
  subject { build :zone }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of(:forwarders).with_message("must contain at least one IPv4 address separated using commas") }

  context "forwarders validation" do
    it "must be a valid IPv4 address" do
      zone = build :zone, forwarders: ","
      expect(zone).to_not be_valid
      expect(zone.errors[:forwarders]).to eq(["must contain at least one IPv4 address separated using commas"])
    end

    it "must be a valid IPv4 address" do
      zone = build :zone, forwarders: "poorly_entered_data;"
      expect(zone).to_not be_valid
      expect(zone.errors[:forwarders]).to eq(["contains an invalid IPv4 address or is not separated using commas"])
    end

    it "must be comma separated" do
      zone = build :zone, forwarders: "127.0.0.1|127.0.0.1"
      expect(zone).to_not be_valid
      expect(zone.errors[:forwarders]).to eq(["contains an invalid IPv4 address or is not separated using commas"])
    end

    it "must be a valid comma separated list of IPv4 addresses" do
      zone = build :zone, forwarders: "127.0.0.1,127.0.0.2"
      expect(zone).to be_valid
    end
  end

  context "kea_forwarders" do
    it "returns a semicolon separated list of IPv4s" do
      zone = build :zone, forwarders: "127.0.0.1,127.0.0.2"
      expect(zone.kea_forwarders).to eq "127.0.0.1;127.0.0.2;"
    end
  end
end
