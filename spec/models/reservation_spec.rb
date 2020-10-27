require "rails_helper"

RSpec.describe Reservation, type: :model do
  subject { build :reservation }

  it { is_expected.to validate_presence_of :ip_address }
  it { is_expected.to validate_presence_of :hw_address }

  context "hostname validation" do
    it { should allow_value("example.com").for(:hostname) }
    it { should allow_value("foo.example.com").for(:hostname) }
    it { should allow_value("foo-bar-1.abc.123.example.com").for(:hostname) }
    it { should allow_value("foo-BAR-1.ABC.123.example.com").for(:hostname) }
    it { should_not allow_value("i_contain_an_at_sign@gov.uk").for(:hostname) }
    it { should_not allow_value("测试.com").for(:hostname) }
  end

  context "hw_address format validation" do
    it { should allow_value("1a:1b:1c:1d:1e:1f").for(:hw_address) }
    it { should allow_value("01:bb:cc:dd:ee:ff").for(:hw_address) }
    it { should allow_value("01:BB:cc:DD:EE:ff").for(:hw_address) }
    it { should_not allow_value("01-bb-cc-dd-ee-ff").for(:hw_address) }
    it { should_not allow_value("01:BB:cc:DD:EE").for(:hw_address) }
    it { should_not allow_value("01:BB:cc:DD:EE:ff:XX:XX").for(:hw_address) }
  end

  it "validates a correct ip address" do
    reservation = build :reservation, ip_address: "10.0.4.1", subnet: build(:subnet, cidr_block: "10.0.4.0/24")
    expect(reservation).to be_valid
  end

  it "validates an incorrect ip address" do
    reservation = build :reservation, ip_address: "10.0.4"
    expect(reservation).not_to be_valid
    expect(reservation.errors[:ip_address]).to eq(["is not a valid IPv4 address"])
  end

  it "is valid if the ip_address is within the subnet CIDR block" do
    subnet = create(:subnet, cidr_block: "10.0.4.0/24")
    reservation = build :reservation, subnet: subnet, ip_address: "10.0.4.20"
    expect(reservation).to be_valid
  end

  it "is invalid if the ip_address is not within the subnet CIDR block" do
    subnet = create(:subnet, cidr_block: "10.0.4.0/24")
    reservation = build :reservation, subnet: subnet, ip_address: "10.0.10.20"
    expect(reservation).to_not be_valid
    expect(reservation.errors[:ip_address]).to eq(["is not within the subnet range"])
  end

  it "is valid if the ip_address is within the subnet start and end address" do
    subnet = create(:subnet, cidr_block: "10.0.4.0/24", start_address: "10.0.4.10", end_address: "10.0.4.100")
    reservation = build :reservation, subnet: subnet, ip_address: "10.0.4.20"
    expect(reservation).to be_valid
  end

  it "is invalid if the ip_address is before the subnet start address" do
    subnet = create(:subnet, cidr_block: "10.0.4.0/24", start_address: "10.0.4.10", end_address: "10.0.4.100")
    reservation = build :reservation, subnet: subnet, ip_address: "10.0.4.5"
    expect(reservation).to_not be_valid
    expect(reservation.errors[:ip_address]).to eq(["is not within the subnet range"])
  end

  it "is invalid if the ip_address is after the subnet end address" do
    subnet = create(:subnet, cidr_block: "10.0.4.0/24", start_address: "10.0.4.10", end_address: "10.0.4.100")
    reservation = build :reservation, subnet: subnet, ip_address: "10.0.4.120"
    expect(reservation).to_not be_valid
    expect(reservation.errors[:ip_address]).to eq(["is not within the subnet range"])
  end
  
  it "is invalid if the ip_address is after the subnet end address" do
    subnet = create(:subnet, cidr_block: "10.0.4.0/24", start_address: "10.0.4.10", end_address: "10.0.4.100")
    reservation = build :reservation, subnet: subnet, ip_address: "10.0.4.120"
    expect(reservation).to_not be_valid
    expect(reservation.errors[:ip_address]).to eq(["is not within the subnet range"])
  end

  it "removes trailing whitespace in hw address" do
    reservation = build :reservation, hw_address: " 1a:1b:1c:1d:1e:1f "
    expect(reservation.hw_address == "1a:1b:1c:1d:1e:1f")
  end
  
  it "removes trailing whitespace in ip address" do
    reservation = build :reservation, ip_address: " 192.0.2.2 "
    expect(reservation.ip_address == "192.0.2.2")
  end
  
  it "removes trailing whitespace in hostname" do
    reservation = build :reservation,  hostname: " test.example.com "
    expect(reservation.hw_address == "test.example.com")
  end
  
  it "is invalid if the hw address is already assigned within the subnet" do
    subnet = create :subnet, cidr_block: "10.0.4.0/24", start_address: "10.0.4.10", end_address: "10.0.4.100"
    reservation1 = create :reservation, subnet: subnet, hw_address: "1a:1b:1c:1d:1e:1f", ip_address: "10.0.4.11"
    reservation2 = build :reservation, subnet: subnet, hw_address: "1a:1b:1c:1d:1e:1f", ip_address: "10.0.4.12"
    expect(reservation2).to_not be_valid
    expect(reservation2.errors[:hw_address]).to eq(["has already been reserved in the subnet"])
  end

  it "is invalid if the ip address is already assigned within the subnet" do
    subnet = create :subnet, cidr_block: "10.0.2.0/24", start_address: "10.0.2.10", end_address: "10.0.2.100"
    reservation1 = create :reservation, subnet: subnet, ip_address: "10.0.2.11"
    reservation2 = build :reservation, subnet: subnet, ip_address: "10.0.2.11"
    expect(reservation2).to_not be_valid
    expect(reservation2.errors[:ip_address]).to eq(["has already been reserved in the subnet"])
  end
  
  it "is invalid if the hostname is already assigned within the subnet" do
    subnet = create :subnet, cidr_block: "10.0.3.0/24", start_address: "10.0.3.10", end_address: "10.0.3.100"
    reservation1 = create :reservation, subnet: subnet, hostname: "test.example.com", ip_address: "10.0.3.11"
    reservation2 = build :reservation, subnet: subnet, hostname: "test.example.com", ip_address: "10.0.3.12"
    expect(reservation2).to_not be_valid
    expect(reservation2.errors[:hostname]).to eq(["has already been reserved in the subnet"])
  end
end
