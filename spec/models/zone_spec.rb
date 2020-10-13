require "rails_helper"

RSpec.describe Zone, type: :model do
  subject { build :zone }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of(:forwarders).with_message("must contain at least one IPv4 address separated using commas") }

  it { should allow_value("example.com").for(:name) }
  it { should allow_value("foo.example.com").for(:name) }
  it { should allow_value("foo-bar-1.abc.123.example.com").for(:name) }
  it { should allow_value("foo-BAR-1.ABC.123.example.com").for(:name) }
  it { should_not allow_value("i_contain_an_at_sign@gov.uk").for(:name) }
  it { should_not allow_value("测试.com").for(:name) }

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

  it "stores the name downcased" do
    zone = create :zone, name: "cAsE.EXamPLE.com"
    expect(zone.name).to eq "case.example.com"
  end
end
