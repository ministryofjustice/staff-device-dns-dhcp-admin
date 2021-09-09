require "dhcp_config_parser"

describe DhcpConfigParser do

  describe ".kea_config_exists?" do
    context "when kea.json is not present" do
      it "returns false" do
        expect(File).to receive(:exist?).and_return(false)
        expect(DhcpConfigParser.kea_config_exists?).to eq(false)
      end
    end

    context "when kea.json is present" do
      it "returns true" do
        expect(File).to receive(:exist?).with("kea.json").and_return(true, true)
        expect(DhcpConfigParser.kea_config_exists?).to eq(true)
      end
    end

  end

  describe ".export_file_exists?" do
    context "when export.txt is not present" do
      it "returns false" do
        expect(File).to receive(:exist?).and_return(false)
        expect(DhcpConfigParser.export_file_exists?).to eq(false)
      end
    end

    context "when export.txt is present" do
      it "returns true" do
        expect(File).to receive(:exist?).with("export.txt").and_return(true, true)
        expect(DhcpConfigParser.export_file_exists?).to eq(true)
      end
    end
  end

  describe "get_kea_reservations" do
    context "given a shared network ID and KEA config file" do    
      let(:kea_config) { File.read("spec/kea.json") }
      let(:shared_network_id) { "FITS_0001" } 
      let(:kea_reservations) { JSON.parse(File.read("spec/reservations.txt")) }

      it "returns an array of hashes containing all reservations" do
        expect(DhcpConfigParser.get_kea_reservations(shared_network_id, kea_config)).to eql(kea_reservations)
      end
    end

    
  end

  describe "get_legacy_reservations" do
    context "given a legacy config file and an array of subnets" do
      let(:reservations) { JSON.parse(File.read("spec/legacy_reservations.txt")) }
      let(:export) { File.read("spec/export.txt") }
      let(:subnet_list) { ["192.168.1.0","192.168.7.0","192.168.2.0"] }

      it "returns an array of hashes containing all reservations for those subnets" do
        expect(DhcpConfigParser.get_legacy_reservations(export, subnet_list)).to eql(reservations)
      end
    end

  end


end



# 1. Smelly stubs 
# 2. tightly coupled / brittle tests
# 3. Slight duplication
# 4. Doing too much - suituational
