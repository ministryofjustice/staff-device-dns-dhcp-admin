require "rails_helper"

RSpec.describe UseCases::FetchLease do
  subject(:use_case) do
    described_class.new(
      gateway: gateway,
      lease_ip_address: ip_address
    )
  end

  let(:hw_address) { double(:hw_address) }
  let(:ip_address) { double(:ip_address) }
  let(:hostname) { double(:hostname) }
  let(:state) { double(:state) }

  let(:response) do
    {
      "hw-address" => hw_address,
      "ip-address" => ip_address,
      "hostname" => hostname,
      "state" => state
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
      state: state
    )
  end
end
