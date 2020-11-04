require "rails_helper"

RSpec.describe ReservationOption, type: :model do
  subject { build :reservation_option }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :reservation }

  it { should allow_value("example.com").for(:domain_name) }
  it { should allow_value("foo.example.com").for(:domain_name) }
  it { should allow_value("foo-bar-1.abc.123.example.com").for(:domain_name) }
  it { should allow_value("foo-BAR-1.ABC.123.example.com").for(:domain_name) }
  it { should_not allow_value("i_contain_an_at_sign@gov.uk").for(:domain_name) }
  it { should_not allow_value("测试.com").for(:domain_name) }

  it "rejects an incorrect routers" do
    option = build :reservation_option, routers: "abcd,efg"
    expect(option).not_to be_valid
    expect(option.errors[:routers]).to eq(["contains an invalid IPv4 address or is not separated using commas"])
  end

  it "is invalid if domain name and routers are not set" do
    option = build :reservation_option, routers: nil, domain_name: nil
    expect(option).not_to be_valid
    expect(option.errors[:base]).to eq(["At least one option must be filled out"])
  end
end
