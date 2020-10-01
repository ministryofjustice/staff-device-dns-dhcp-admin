require "rails_helper"

RSpec.describe Option, type: :model do
  subject { build :option }

  it { is_expected.to validate_presence_of :routers }
  it { is_expected.to validate_presence_of :domain_name_servers	 }
  it { is_expected.to validate_presence_of :domain_name }


  it "rejects an incorrect routers" do
    option = build :option, routers: "abcd,efg"
    expect(option).not_to be_valid
    expect(option.errors[:routers]).to eq(["contains an invalid IPv4 address"])
  end

  it "rejects an incorrect domain_name_server" do
    option = build :option, domain_name_servers: "abcd,efg"
    expect(option).not_to be_valid
    expect(option.errors[:domain_name_servers]).to eq(["contains an invalid IPv4 address"])
  end


  it "validates some routers" do
    option = build :option, routers: "10.0.3.1,10.0.3.3"
    expect(option).to be_valid
  end

  it "validates some domain_name_servers" do
    option = build :option, routers: "10.0.3.1,10.0.3.3"
    expect(option).to be_valid
  end
end
