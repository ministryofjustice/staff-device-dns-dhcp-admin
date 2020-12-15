require "rails_helper"

RSpec.describe UseCases::FetchLeases do
  subject(:use_case) do
    described_class.new(
      gateway: gateway,
      subnet_kea_id: subnet_kea_id
    )
  end

  let(:hw_address) { :hw_address }
  let(:ip_address) { :ip_address }
  let(:hostname) { :hostname }
  let(:subnet_kea_id) { :subnet_kea_id }

  let(:response) do
    [
      {
        "hw-address" => hw_address,
        "ip-address" => ip_address,
        "hostname" => hostname,
        "state" => 1
      }
    ]
  end

  let(:gateway) do
    instance_double(Gateways::KeaControlAgent, fetch_leases: response)
  end

  it "returns an object with the correct attributes" do
    expect(use_case.call).to match_array([
      have_attributes(
        class: Lease,
        hw_address: hw_address,
        ip_address: ip_address,
        hostname: hostname,
        state: 1
      )
    ])
  end

  context "when no leases are returned from the gateway" do
    let(:response) do
      []
    end

    it "returns an empty array" do
      expect(use_case.call).to eq []
    end
  end
end
