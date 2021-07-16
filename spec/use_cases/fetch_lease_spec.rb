require "rails_helper"

RSpec.describe UseCases::FetchLease do
  subject(:use_case) do
    described_class.new(
      gateway: gateway,
      lease_ip_address: ip_address
    )
  end

  let(:hw_address)     { double(:hw_address) }
  let(:ip_address)     { double(:ip_address) }
  let(:hostname)       { double(:hostname) }
  let(:state)          { double(:state) }
  let(:kea_subnet_id)  { double(:kea_subnet_id) }

  let(:response) do
    {
      "hw-address" => hw_address,
      "ip-address" => ip_address,
      "hostname" => hostname,
      "state" => state,
      "subnet-id" => kea_subnet_id
    }
  end

  let(:gateway) do
    double(:gateway, fetch_lease: response)
  end

  it "returns a Lease" do
    expect(use_case.call).to have_attributes(
      class: Lease,
      hw_address: hw_address,
      ip_address: ip_address,
      hostname: hostname,
      state: state,
      kea_subnet_id: kea_subnet_id
    )
  end
end
