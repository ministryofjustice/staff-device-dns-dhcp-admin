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
      let(:lease) { instance_double(Lease, ip_address: '192.168.0.15') }
      let(:leases) { [lease] }

      before do
        create :reservation, subnet: subnet, ip_address: "192.168.0.15"
      end

      it "returns 9" do
        expect(subject.num_remaining_ips).to eql(9)
      end
    end

    context "when there are leases and they were not reserved" do
      let(:lease) { instance_double(Lease, ip_address: '192.168.0.16') }
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
        let(:lease) { instance_double(Lease, ip_address: '192.168.0.16') }
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
        let(:lease) { instance_double(Lease, ip_address: '192.168.0.18') }
        let(:leases) { [lease] }

        context "and the leases weren't reserved" do
          it "returns 7" do

            printf "\nExclusions - Start Address: \t\t\t" + subnet.exclusions[0].start_address + "\n" 
            printf "Exclusions - End Address: \t\t\t" + subnet.exclusions[0].end_address + "\n" 
            printf "Lease IP: \t\t\t\t\t" + subject.leases[0].ip_address + "\n" 
            printf "Total Reservations outside of Exclusions: \t" + subject.reservations_outside_of_exclusions.count.to_s + "\n" 
            printf "Total Addresses: \t\t\t\t" + subnet.total_addresses.to_s + "\n" 
            printf "Dynamically Allocatable IPs: \t\t\t" + subject.dynamically_allocatable_ips.to_s + "\n" 
            printf "Number of Leased reserved IP addresses: \t" + subject.leased_reserved_ip_addresses.count.to_s + "\n" 
            printf "Number of Leases: \t\t\t\t" + subject.leases.count.to_s + "\n" 
            printf "Number of Leases not reserved: \t\t\t" + subject.unreserved_leases.count.to_s + "\n"
            printf "############################################################" + "\n\n"
            
            expect(subject.num_remaining_ips).to eql(7)
          end
        end
        
        context "and the leases were reserved and reservation was outside the exclusion" do
          before do
            create :reservation, subnet: subnet, ip_address: "192.168.0.18"
          end

          it "returns 7" do

            printf "\nExclusions - Start Address: \t\t\t" + subnet.exclusions[0].start_address + "\n" 
            printf "Exclusions - End Address: \t\t\t" + subnet.exclusions[0].end_address + "\n" 
            printf "Lease IP: \t\t\t\t\t" + subject.leases[0].ip_address + "\n" 
            printf "Total Reservations outside of Exclusions: \t" + subject.reservations_outside_of_exclusions.count.to_s + "\n" 
            printf "Total Addresses: \t\t\t\t" + subnet.total_addresses.to_s + "\n" 
            printf "Dynamically Allocatable IPs: \t\t\t" + subject.dynamically_allocatable_ips.to_s + "\n" 
            printf "Number of Leased Reserved IP addresses: \t" + subject.leased_reserved_ip_addresses.count.to_s + "\n" 
            printf "Number of Leases: \t\t\t\t" + subject.leases.count.to_s + "\n" 
            printf "############################################################" + "\n\n"

            expect(subject.num_remaining_ips).to eql(7)
          end
        end        
      end

      context "when there are lease inside exclusion" do
        let(:lease) { instance_double(Lease, ip_address: '192.168.0.16') }
        let(:leases) { [lease] }

        it "returns 8" do
          expect(subject.num_remaining_ips).to eql(8)
        end
      end
    end
  end
end