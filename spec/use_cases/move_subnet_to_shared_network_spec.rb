require "rails_helper"

RSpec.describe UseCases::MoveSubnetToSharedNetwork do
  let(:subnet) { create :subnet }
  let(:shared_network) { create :shared_network }

  it "returns truthy" do
    expect(subject.call(subnet, shared_network)).to be_truthy
  end

  it "moves a subnet from one shared network to another shared network" do
    subject.call(subnet, shared_network)
    expect(shared_network.subnets).to include(subnet)
  end

  it "deletes the leftover empty shared network" do
    subnet_shared_network_id = subnet.shared_network_id
    subject.call(subnet, shared_network)
    expect(SharedNetwork.find_by(id: subnet_shared_network_id)).to eq(nil)
  end

  context "when the subnet is moved from a shared network that contains other subnets" do
    before do
      create :subnet, shared_network: subnet.shared_network
    end

    it "returns truthy" do
      expect(subject.call(subnet, shared_network)).to be_truthy
    end

    it "does not destroy the shared network" do
      subnet_shared_network_id = subnet.shared_network_id
      subject.call(subnet, shared_network)
      expect(SharedNetwork.find_by(id: subnet_shared_network_id)).not_to eq(nil)
    end
  end

  context "when the move fails" do
    let(:shared_network) { nil }

    it "returns falsey" do
      expect(subject.call(subnet, shared_network)).to be_falsey
    end
  end
end
