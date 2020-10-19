require "rails_helper"

RSpec.describe Option, type: :model do
  subject { build :option }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :subnet }

  it "is invalid if none of the options are completed" do
    subject.routers = nil
    subject.domain_name_servers = nil
    subject.domain_name = nil

    expect(subject).not_to be_valid
    expect(subject.errors[:base]).to include("At least one option must be filled out")
  end

  it "rejects an incorrect routers" do
    option = build :option, routers: ["abcd", "efg"]
    expect(option).not_to be_valid
    expect(option.errors[:routers]).to eq(["contains an invalid IPv4 address or is not separated using commas"])
  end

  it "rejects an incorrect domain_name_server" do
    option = build :option, domain_name_servers: ["abcd", "efg"]
    expect(option).not_to be_valid
    expect(option.errors[:domain_name_servers]).to eq(["contains an invalid IPv4 address or is not separated using commas"])
  end

  describe "#routers" do
    context "when routers is nil" do
      before do
        subject.routers = nil
      end

      it "returns an empty array" do
        expect(subject.routers).to eq([])
      end
    end

    context "when routers is not empty" do
      before do
        subject.routers = "192.168.0.2,192.168.0.3"
      end

      it "returns an empty array" do
        expect(subject.routers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end
  end

  describe "#routers=" do
    context "when the value is a string" do
      before do
        subject.routers = "192.168.0.2,192.168.0.3"
      end

      it "returns an empty array" do
        expect(subject.routers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end

    context "when the value is an array" do
      before do
        subject.routers = ["192.168.0.2", "192.168.0.3"]
      end

      it "returns an empty array" do
        expect(subject.routers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end

    context "when the value is an string with whitespace" do
      subject { create :option, routers: " 192.168.0.2, 192.168.0.3  " }

      it "stores the routers correctly" do
        expect(subject.routers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end
  end

  describe "#domain_name_servers" do
    context "when domain_name_servers is nil" do
      before do
        subject.domain_name_servers = nil
      end

      it "returns an empty array" do
        expect(subject.domain_name_servers).to eq([])
      end
    end

    context "when domain_name_servers is not empty" do
      before do
        subject.domain_name_servers = "192.168.0.2,192.168.0.3"
      end

      it "returns an empty array" do
        expect(subject.domain_name_servers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end
  end

  describe "#domain_name_servers=" do
    context "when the value is a string" do
      before do
        subject.domain_name_servers = "192.168.0.2,192.168.0.3"
      end

      it "returns an empty array" do
        expect(subject.domain_name_servers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end

    context "when the value is an array" do
      before do
        subject.domain_name_servers = ["192.168.0.2", "192.168.0.3"]
      end

      it "returns an empty array" do
        expect(subject.domain_name_servers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end
  end
end
