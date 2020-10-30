require "rails_helper"

RSpec.describe GlobalOption, type: :model do
  subject { build :global_option }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it do
    is_expected.to validate_presence_of(:routers)
      .with_message("must contain at least one IPv4 address separated using commas")
  end

  it do
    is_expected.to validate_presence_of(:domain_name_servers)
      .with_message("must contain at least one IPv4 address separated using commas")
  end

  it { is_expected.to validate_presence_of :domain_name }
  it { is_expected.to validate_numericality_of(:valid_lifetime).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:valid_lifetime).only_integer }

  it "rejects invalid routers" do
    option = build :option, routers: "abcd,efg"
    expect(option).not_to be_valid
    expect(option.errors[:routers]).to eq(["contains an invalid IPv4 address or is not separated using commas"])
  end

  it "rejects invalid domain_name_servers" do
    option = build :option, domain_name_servers: "abcd,efg"
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

      it "stores the routers correctly" do
        expect(subject.routers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end
  end

  describe "#routers=" do
    context "when the value is a string" do
      before do
        subject.routers = "192.168.0.2,192.168.0.3"
      end

      it "stores the routers correctly" do
        expect(subject.routers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end

    context "when the value is an string with whitespace" do
      subject { create :global_option, routers: " 192.168.0.2, 192.168.0.3  " }

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

      it "stores the domain_name_servers correctly" do
        expect(subject.domain_name_servers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end
  end

  describe "#domain_name_servers=" do
    context "when the value is a string" do
      before do
        subject.domain_name_servers = "192.168.0.2,192.168.0.3"
      end

      it "stores the domain_name_servers correctly" do
        expect(subject.domain_name_servers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end

    context "when the value is an string with whitespace" do
      subject { create :global_option, domain_name_servers: " 192.168.0.2, 192.168.0.3  " }

      it "stores the domain_name_servers correctly" do
        expect(subject.domain_name_servers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end
  end

  it "can only have 1 record in the database" do
    create(:global_option)

    new_global_option = build(:global_option)
    expect(new_global_option).to_not be_valid
    expect(new_global_option.errors[:base]).to include "A global option already exists"
  end
end
