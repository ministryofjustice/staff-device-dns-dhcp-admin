require "rails_helper"

RSpec.describe Subnet, type: :model do
  subject { build :subnet }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :cidr_block }
  it { is_expected.to validate_uniqueness_of(:cidr_block).case_insensitive }
  it { is_expected.to validate_presence_of :start_address }
  it { is_expected.to validate_presence_of :end_address }
  it { is_expected.to validate_presence_of :routers }

  it "is valid by default" do
    subnet = build :subnet
    expect(subnet).to be_valid
  end

  it "validates an incorrect CIDR block" do
    subnet = build :subnet, cidr_block: "10.0.4.0/abcd"
    expect(subnet).not_to be_valid
    expect(subnet.errors[:cidr_block]).to eq(["is not a valid IPv4 subnet"])
  end

  it "validates an incorrect start address" do
    subnet = build :subnet, start_address: "10.0.4"
    expect(subnet).not_to be_valid
    expect(subnet.errors[:start_address]).to eq(["is not a valid IPv4 address"])
  end

  it "validates an incorrect end address" do
    subnet = build :subnet, end_address: "10.0.4"
    expect(subnet).not_to be_valid
    expect(subnet.errors[:end_address]).to eq(["is not a valid IPv4 address"])
  end

  it "rejects an incorrect routers" do
    subnet = build :subnet, routers: "abcd,efg"
    expect(subnet).not_to be_valid
    expect(subnet.errors[:routers]).to eq(["contains an invalid IPv4 address or is not separated using commas"])
  end

  it "validates cidr_block is unique by the address" do
    existing_subnet = create :subnet
    subnet = build :subnet, cidr_block: existing_subnet.cidr_block.gsub("/24", "/20")

    expect(subnet).not_to be_valid
    expect(subnet.errors[:cidr_block]).to eq(["matches a subnet with the same address"])
  end

  it "does not append the subnet address validation when the cidr_block matches exactly" do
    existing_subnet = create :subnet
    subnet = build :subnet, cidr_block: existing_subnet.cidr_block

    expect(subnet).not_to be_valid
    expect(subnet.errors[:cidr_block]).to_not include "matches a subnet with the same address"
  end

  it "validates the start address is within the subnet range" do
    subnet = build :subnet, cidr_block: "10.0.4.0/30", start_address: "10.0.4.20", end_address: "10.0.4.100"
    expect(subnet).not_to be_valid
    expect(subnet.errors[:start_address]).to include("is not within the subnet range")
  end

  it "validates the end address is within the subnet range" do
    subnet = build :subnet, cidr_block: "10.0.4.0/30", start_address: "10.0.4.1", end_address: "10.0.4.20"
    expect(subnet).not_to be_valid
    expect(subnet.errors[:end_address]).to eq(["is not within the subnet range"])
  end

  it "validates the start address matches the host address" do
    subnet = build :subnet, cidr_block: "10.0.4.0/24", start_address: "10.0.5.1", end_address: "10.0.4.100"
    expect(subnet).not_to be_valid
    expect(subnet.errors[:start_address]).to eq(["is not within the subnet range"])
  end

  it "validates the end address matches the host address" do
    subnet = build :subnet, cidr_block: "10.0.4.0/24", start_address: "10.0.4.1", end_address: "10.0.5.100"
    expect(subnet).not_to be_valid
    expect(subnet.errors[:end_address]).to eq(["is not within the subnet range"])
  end

  it "removes trailing whitespace in CIDR block" do
    subnet = build :subnet, cidr_block: " 10.0.4.0/24 ", start_address: "10.0.4.1", end_address: "10.0.5.100"
    expect(subnet.cidr_block).to eq("10.0.4.0/24")
  end

  it "removes trailing whitespace in start address" do
    subnet = build :subnet, cidr_block: "10.0.4.0/24", start_address: " 10.0.4.1 ", end_address: "10.0.5.100"
    expect(subnet.start_address).to eq("10.0.4.1")
  end

  it "removes trailing whitespace in end address" do
    subnet = build :subnet, cidr_block: "10.0.4.0/24", start_address: "10.0.4.1", end_address: " 10.0.5.100 "
    expect(subnet.end_address).to eq("10.0.5.100")
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

    context "when the value is an string with whitespace" do
      subject { create :subnet, routers: " 192.168.0.2, 192.168.0.3  " }

      it "stores the routers correctly" do
        expect(subject.routers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end
  end

  describe "#total_addresses" do
    before do
      subject.start_address = "192.168.0.251"
      subject.end_address = "192.168.1.5"
    end

    context "with no exclusions or reservations" do
      it "returns number of total IPs between the start_address and end_address" do
        expect(subject.total_addresses).to eq(11)
      end
    end

    context "with an exclusion range" do
      before do
        subject.exclusions.build(
          start_address: "192.168.0.255",
          end_address: "192.168.1.3"
        )
      end

      it "returns number of total IPs between the start_address and end_address minus exclusions" do
        expect(subject.total_addresses).to eq(6)
      end
    end
  end
end
