require "rails_helper"

RSpec.describe Option, type: :model do
  subject { build :option }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "is invalid with no routers" do
    subject.routers = []
    expect(subject).not_to be_valid
    expect(subject.errors[:routers]).to include("must contain at least one IPv4 address")
  end

  it "is invalid with no domain_name_servers" do
    subject.domain_name_servers = []
    expect(subject).not_to be_valid
    expect(subject.errors[:domain_name_servers]).to include("must contain at least one IPv4 address")
  end

  it { is_expected.to validate_presence_of :domain_name }

  it "rejects an incorrect routers" do
    option = build :option, routers: ["abcd", "efg"]
    expect(option).not_to be_valid
    expect(option.errors[:routers]).to eq(["contains an invalid IPv4 address"])
  end

  it "rejects an incorrect domain_name_server" do
    option = build :option, domain_name_servers: ["abcd", "efg"]
    expect(option).not_to be_valid
    expect(option.errors[:domain_name_servers]).to eq(["contains an invalid IPv4 address"])
  end
end
