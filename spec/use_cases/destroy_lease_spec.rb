require "rails_helper"

RSpec.describe UseCases::DestroyLease do
  subject(:use_case) do
    described_class.new(
      gateway: gateway,
      lease_ip_address: ip_address
    )
  end

  let(:ip_address) { double(:ip_address) }

  let(:gateway) { double(:gateway, destroy_lease: true) }

  it "Destroys a Lease" do
    expect(use_case.call).to eql(true)
    expect(gateway).to have_received(:destroy_lease).with(ip_address)
  end
end
