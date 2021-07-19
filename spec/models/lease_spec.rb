require "rails_helper"

RSpec.describe Lease, type: :model do
  describe "#subnet" do
    context "when a subnet with kea_id exists" do
      let(:subnet) { create(:subnet) }
      subject { described_class.new(kea_subnet_id: subnet.kea_id) }

      it "returns a subnet object" do
        expect(subject.subnet).to eql(subnet)
      end
    end
  end
end
