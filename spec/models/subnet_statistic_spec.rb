require "rails_helper"

RSpec.describe SubnetStatistic do
  let(:subnet) do 
    create :subnet, 
      cidr_block: "192.168.0.0/24",
      start_address: "192.168.0.11", 
      end_address: "192.168.0.20"
  end
  subject { described_class.new(subnet: subnet, leases: leases) }

  describe "#num_remaining_ips" do
    context "when there are no leases" do
      let(:leases) { [] }

      it "returns 10" do
        expect(subject.num_remaining_ips).to eql(10)
      end

      context "when there are reservations between the start and end addresses" do
        before do
          create :reservation, subnet: subnet, ip_address: "192.168.0.15"
        end

        it "returns 9" do
          expect(subject.num_remaining_ips).to eql(9)  
        end
      end

      context "when there are reservations outside the the start and end addresses"
    end

    context "when there are leases" do
      let(:lease) { instance_double(Lease) }
      let(:leases) { [lease] }

      it "returns 9" do
        expect(subject.num_remaining_ips).to eql(9)
      end
    end
  end
end