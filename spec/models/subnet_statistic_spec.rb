require "rails_helper"

RSpec.describe SubnetStatistic do
  let(:subnet) do
    create :subnet,
      cidr_block: "192.168.0.0/24",
      start_address: "192.168.0.11",
      end_address: "192.168.0.20"
  end
  let(:leases) { [] }
  subject { described_class.new(subnet: subnet, leases: leases) }

  describe "#num_remaining_ips" do
    context "when there are no leases" do
      let(:leases) { [] }

      it "returns 10" do
        expect(subject.num_remaining_ips).to eql(10)
      end

      context "when there are exclusions" do
        before do
          create :exclusion, subnet: subnet, start_address: "192.168.0.15", end_address: "192.168.0.16"
        end

        context "when there are reservations outside the range of the exclusion" do
          before do
            create :reservation, subnet: subnet, ip_address: "192.168.0.14"
          end

          it "returns 7" do
            expect(subject.num_remaining_ips).to eql(7)
          end
        end

        context "and there are reservations in the range of the exclusion" do
          before do
            create :reservation, subnet: subnet, ip_address: "192.168.0.15"
          end

          it "returns 8" do
            expect(subject.num_remaining_ips).to eql(8)
          end
        end
      end
    end

    context "when there are leases and they were reserved" do
      let(:lease) { instance_double(Lease, ip_address: "192.168.0.15") }
      let(:leases) { [lease] }

      before do
        create :reservation, subnet: subnet, ip_address: "192.168.0.15"
      end

      it "returns 9" do
        expect(subject.num_remaining_ips).to eql(9)
      end
    end

    context "when there are leases and they were not reserved" do
      let(:lease) { instance_double(Lease, ip_address: "192.168.0.16") }
      let(:leases) { [lease] }

      before do
        create :reservation, subnet: subnet, ip_address: "192.168.0.15"
      end

      it "returns 8" do
        expect(subject.num_remaining_ips).to eql(8)
      end
    end

    context "when there are no exclusions" do
      context "when there are leases" do
        let(:lease) { instance_double(Lease, ip_address: "192.168.0.16") }
        let(:leases) { [lease] }

        context "and the leases were reserved" do
          before do
            create :reservation, subnet: subnet, ip_address: "192.168.0.16"
          end

          it "returns 9" do
            expect(subject.num_remaining_ips).to eql(9)
          end
        end
        context "and the leases were not reserved" do
          it "returns 9" do
            expect(subject.num_remaining_ips).to eql(9)
          end
        end
      end
    end

    context "when there are exclusions" do
      before do
        create :exclusion, subnet: subnet, start_address: "192.168.0.15", end_address: "192.168.0.16"
      end
      context "when there are leases outside exclusion" do
        let(:lease) { instance_double(Lease, ip_address: "192.168.0.18") }
        let(:leases) { [lease] }

        context "and the leases weren't reserved" do
          it "returns 7" do
            expect(subject.num_remaining_ips).to eql(7)
          end
        end

        context "and the leases were reserved and reservation was outside the exclusion" do
          before do
            create :reservation, subnet: subnet, ip_address: "192.168.0.18"
          end

          it "returns 7" do
            expect(subject.num_remaining_ips).to eql(7)
          end
        end
      end

      context "when there are lease inside exclusion" do
        let(:lease) { instance_double(Lease, ip_address: "192.168.0.16") }
        let(:leases) { [lease] }

        it "returns 8" do
          expect(subject.num_remaining_ips).to eql(8)
        end
      end
    end
  end

  describe "#reservations_outside_of_exclusions:" do
    it "returns an empty list" do
      expect(subject.reservations_outside_of_exclusions).to eql([])
    end

    it "returns list of reservations when there are reservations" do
      reservation = create :reservation, subnet: subnet
      expect(subject.reservations_outside_of_exclusions).to eql([reservation])
    end

    context "when there are exclusions," do
      before do
        create :exclusion, subnet: subnet, start_address: "192.168.0.15", end_address: "192.168.0.16"
      end

      it "does not return any reservations when they are within the exclusion ranges" do
        reservation = create :reservation, subnet: subnet, ip_address: "192.168.0.16"
        expect(subject.reservations_outside_of_exclusions).not_to include(reservation)
      end

      it "returns the reservations when they are outside the exclusion ranges" do
        reservation = create :reservation, subnet: subnet, ip_address: "192.168.0.17"
        expect(subject.reservations_outside_of_exclusions).to eql([reservation])
      end
    end
  end

  describe "#leases_not_in_exclusion_zones:" do
    it "returns empty list when there are no leases" do
      expect(subject.leases_not_in_exclusion_zones).to eql([])
    end

    context "when there are leases" do
      let(:lease) { instance_double(Lease, ip_address: "192.168.0.16") }
      let(:leases) { [lease] }

      it "returns leases when there are some" do
        expect(subject.leases_not_in_exclusion_zones).to eql(leases)
      end

      it "returns leases when there are some and they are outside the exclusion ranges" do
        create :exclusion, subnet: subnet, start_address: "192.168.0.14", end_address: "192.168.0.15"

        expect(subject.leases_not_in_exclusion_zones).to eql(leases)
      end

      it "does not return leases even when there are some but they are within exclusion ranges" do
        create :exclusion, subnet: subnet, start_address: "192.168.0.15", end_address: "192.168.0.16"

        expect(subject.leases_not_in_exclusion_zones).not_to include(lease)
      end

      context "where are leases inside and on the outside of the exclusions" do
        let(:lease_in_exclusion_zone) { instance_double(Lease, ip_address: "192.168.0.16") }
        let(:lease_not_in_exclusion_zone) { instance_double(Lease, ip_address: "192.168.0.17") }
        let(:leases) { [lease_in_exclusion_zone, lease_not_in_exclusion_zone] }

        before do
          create :exclusion, subnet: subnet, start_address: "192.168.0.15", end_address: "192.168.0.16"
        end

        it "returns the leases that are not inside of any exclusion ranges" do
          expect(subject.leases_not_in_exclusion_zones).to include(lease_not_in_exclusion_zone)
        end

        it "does not return the leases that are inside of exclusion ranges" do
          expect(subject.leases_not_in_exclusion_zones).not_to include(lease_in_exclusion_zone)
        end
      end
    end
  end

  describe "#leased_reserved_ip_addresses:" do
    it "returns an empty list when there are no leases" do
      expect(subject.leased_reserved_ip_addresses).to eql([])
    end

    context "when there are leases," do
      let(:lease_reserved) { instance_double(Lease, ip_address: "192.168.0.15") }
      let(:lease_not_reserved) { instance_double(Lease, ip_address: "192.168.0.16") }
      let(:leases) { [lease_reserved, lease_not_reserved] }

      before do
        create :reservation, subnet: subnet, ip_address: "192.168.0.15"
      end

      it "returns leases that are reserved" do
        expect(subject.leased_reserved_ip_addresses).to include(lease_reserved)
      end

      it "does not return leases that are not reserved" do
        expect(subject.leased_reserved_ip_addresses).not_to include(lease_not_reserved)
      end

      it "does not return leases that are reserved but they are inside of exclusion ranges" do
        create :exclusion, subnet: subnet, start_address: "192.168.0.14", end_address: "192.168.0.15"

        expect(subject.leased_reserved_ip_addresses).not_to include(lease_reserved)
      end
    end
  end
end
