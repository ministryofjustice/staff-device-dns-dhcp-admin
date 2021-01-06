require "rails_helper"

RSpec.describe ClientClass, type: :model do
  subject { build :client_class }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { should allow_value("example.com").for(:domain_name) }
  it { should allow_value("foo.example.com").for(:domain_name) }
  it { should allow_value("foo-bar-1.abc.123.example.com").for(:domain_name) }
  it { should allow_value("foo-BAR-1.ABC.123.example.com").for(:domain_name) }
  it { should_not allow_value("i_contain_an_at_sign@gov.uk").for(:domain_name) }
  it { should_not allow_value("测试.com").for(:domain_name) }
  it { should_not allow_value("me.example/.co").for(:domain_name) }

  it { should allow_value("AbC123-").for(:client_id) }
  it { should_not allow_value("abC.123-").for(:client_id) }
  it { should_not allow_value("测试.com").for(:client_id) }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :client_id }

  it do
    is_expected.not_to allow_value("abC.123-")
      .for(:client_id)
      .with_message("must contain only letters, numbers, underscores and dashes")
  end

  it do
    is_expected.to validate_presence_of(:domain_name_servers)
      .with_message("must contain at least one IPv4 address separated using commas")
  end

  it { is_expected.to validate_presence_of :domain_name }

  it "strips whitespace from client_id" do
    client = create :client_class, client_id: "  TEST  "
    expect(client.client_id).to eq "TEST"
  end

  it "strips whitespace from domain_name" do
    client = create :client_class, domain_name: "  test.example.com  "
    expect(client.domain_name).to eq "test.example.com"
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
      subject { create :client_class, domain_name_servers: " 192.168.0.2, 192.168.0.3  " }

      it "stores the domain_name_servers correctly" do
        expect(subject.domain_name_servers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end

    context "when the value is invalid" do
      subject { build :client_class, domain_name_servers: "abcd,efg" }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:domain_name_servers]).to eq(["contains an invalid IPv4 address or is not separated using commas"])
      end
    end
  end

  it "name cannot be prefixed with the word 'subnet'" do
    client_class = build(:client_class, name: "subnet-1234")
    expect(client_class).to_not be_valid
    expect(client_class.errors[:name]).to include("cannot begin with the word 'subnet'")
  end
end
