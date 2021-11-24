require "rails_helper"

describe DhcpConfigParser do
  let(:kea_config_json) { File.read("./spec/lib/data/kea.json") }
  let(:legacy_config_filepath) { "./spec/lib/data/export.txt" }
  let(:subnet_list) { ["192.168.1.0", "192.168.2.0"] }
  let(:fits_id) { "FITS_1646" }
  subject { described_class.new(kea_config_json: kea_config_json, legacy_config_filepath: legacy_config_filepath) }

  describe "#run" do
    before do
      create(:subnet, cidr_block: "192.168.1.0/24", start_address: "192.168.1.1", end_address: "192.168.1.255")
      create(:subnet, cidr_block: "192.168.2.0/24", start_address: "192.168.2.1", end_address: "192.168.2.255")
    end

    it "runs" do
      expect(subject.run(fits_id: fits_id, subnet_list: subnet_list)).not_to be_nil
    end

    it "returns an array of data about IP reservations" do
      expect(subject.run(fits_id: fits_id, subnet_list: subnet_list)).to include(hash_including("hw-address", "kea", "legacy"))
    end

    it "creates reservations from the legacy config which do not exist in the kea config" do
      described_class.new(legacy_config_filepath: "./spec/lib/data/brand_new_reservation.txt", kea_config_json: kea_config_json)
        .run(fits_id: fits_id, subnet_list: subnet_list)

      expect(Reservation.count).to eql(2)
    end
  end

  describe "#reservations_by_subnet" do
    it "groups missing reservations by subnets" do
      reservation = {
        "hw-address" => "aabbcc66ffee",
        "kea" => nil,
        "legacy" => {
          "ip-address" => "192.168.1.50",
          "hw-address" => "aabbcc66ffee",
          "hostname" => "win6.test.space.local."
        }
      }
      compared_reservations = [reservation]

      result = subject.reservations_by_subnet(compared_reservations)

      expect(result["192.168.1."]).to eq([reservation])
    end
  end

  describe "#create_reservations" do
    before do
      create(:subnet, cidr_block: "192.168.1.0/24", start_address: "192.168.1.1", end_address: "192.168.1.255")
    end

    it "creates a reservation" do
      reservations_by_subnet = {
        "192.168.1." => [
          {
            "hw-address" => "aabbcc66ffee",
            "kea" => nil,
            "legacy" => {
              "ip-address" => "192.168.1.50",
              "hw-address" => "aabbcc66ffee",
              "hostname" => "win6.test.space.local."
            }
          }
        ]
      }

      expect { subject.create_reservations(reservations_by_subnet) }.to change { Reservation.count }.by(1)
    end
  end

  describe ".export_file_exists?" do
    context "when export.txt is not present" do
      it "returns false" do
        expect(File).to receive(:exist?).and_return(false)
        expect(subject.export_file_exists?).to eq(false)
      end
    end

    context "when export.txt is present" do
      it "returns true" do
        expect(File).to receive(:exist?).with("./spec/lib/data/export.txt").and_return(true)
        expect(subject.export_file_exists?).to eq(true)
      end
    end
  end

  describe "get_kea_reservations" do
    context "given a shared network ID and KEA config file" do
      let(:kea_config) { File.read("spec/lib/data/kea.json") }
      let(:shared_network_id) { "FITS_0001" }
      let(:kea_reservations) { JSON.parse(File.read("spec/lib/data/reservations.txt")) }

      it "returns an array of hashes containing all reservations" do
        expect(subject.get_kea_reservations(shared_network_id, kea_config)).to eql(kea_reservations)
      end
    end
  end

  describe "get_legacy_reservations" do
    context "given a legacy config file and an array of subnets" do
      let(:reservations) { JSON.parse(File.read("spec/lib/data/legacy_reservations.txt")) }
      let(:export) { File.read("spec/lib/data/export.txt") }
      let(:subnet_list) { ["192.168.1.0", "192.168.7.0", "192.168.2.0"] }

      it "returns an array of hashes containing all reservations for those subnets" do
        expect(subject.get_legacy_reservations(export, subnet_list)).to eql(reservations)
      end
    end
  end

  describe "find_missing_reservations" do
    let(:kea_reservations) { JSON.parse(File.read("spec/lib/data/reservations.txt")) }
    let(:legacy_reservations) { JSON.parse(File.read("spec/lib/data/legacy_reservations.txt")) }

    it "returns true if both hashes are equal" do
      expect(
        subject.find_missing_reservations(kea_reservations: kea_reservations, legacy_reservations: legacy_reservations)
      ).to match_array([
        {
          "hw-address" => "a1b2c3d439b9",
          "kea" => {
            "hw-address" => "a1b2c3d439b9",
            "ip-address" => "192.168.7.31",
            "hostname" => "windowsmachine3.test.space.local"
          },
          "legacy" => nil
        },
        {
          "hw-address" => "f6b1d4b2aad2",
          "kea" => {
            "hw-address" => "f6:b1:d4:b2:aa:d2",
            "ip-address" => "192.168.7.253",
            "hostname" => "printer4.test.space.local"
          },
          "legacy" => nil
        },
        {
          "hw-address" => "ccddc3d4e5f7",
          "kea" => {
            "hw-address" => "ccddc3d4e5f7",
            "ip-address" => "192.168.7.30",
            "hostname" => "windowsmachine4.test.space.local",
            "user-context" => {"description" => "Test Site LOAP166"}
          },
          "legacy" => nil
        },
        {
          "hw-address" => "f6aad4b2bbd9",
          "kea" => {
            "hw-address" => "f6:aa:d4:b2:bb:d9",
            "ip-address" => "192.168.7.252",
            "hostname" => "printer3.test.space.local"
          },
          "legacy" => nil
        },
        {
          "hw-address" => "0000aaabbc02",
          "kea" => nil,
          "legacy" => {
            "hw-address" => "0000aaabbc02",
            "ip-address" => "192.168.2.249",
            "hostname" => "win6.test.space.local."
          }
        },
        {
          "hw-address" => "0000aabbc015",
          "kea" => nil,
          "legacy" => {
            "hw-address" => "0000aabbc015",
            "ip-address" => "192.168.2.219",
            "hostname" => "win7.test.space.local"
          }
        },
        {
          "hw-address" => "0000223656de",
          "kea" => nil,
          "legacy" => {
            "hw-address" => "0000223656de",
            "ip-address" => "192.168.2.239",
            "hostname" => "prn6.test.space.local"
          }
        },
        {
          "hw-address" => "0000223656df",
          "kea" => nil,
          "legacy" => {
            "hw-address" => "0000223656df",
            "ip-address" => "192.168.2.221",
            "hostname" => "prn7.test.space.local"
          }
        }
      ])
    end
  end

  describe "get_legacy_exclusions" do
    let(:export) { File.read("spec/lib/data/export.txt") }
    let(:subnet_list) { ["192.168.1.0", "192.168.7.0", "192.168.2.0"] }
    it "returns a hash of all exclusions for the given list of subnets" do
      expect(subject.get_legacy_exclusions(export, subnet_list)).to match_array([
        {
          "type" => "excluderange",
          "start-ip" => "192.168.1.1",
          "end-ip" => "192.168.1.39"
        },
        {
          "type" => "excluderange",
          "start-ip" => "192.168.1.40",
          "end-ip" => "192.168.1.120"
        },
        {
          "type" => "excluderange",
          "start-ip" => "192.168.2.1",
          "end-ip" => "192.168.2.39"
        },
        {
          "type" => "excluderange",
          "start-ip" => "192.168.2.121",
          "end-ip" => "192.168.2.200"
        }
      ])
    end
  end
end
