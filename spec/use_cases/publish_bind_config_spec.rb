require "rails_helper"

describe UseCases::PublishBindConfig do
  subject(:use_case) do
    described_class.new(
      destination_gateway: s3_gateway
    )
  end

  let(:s3_gateway) { instance_spy(Gateways::S3) }
  let(:config) do
    %(
      "zone "1.168.192.in-addr.arpa" {
        type master;
        notify no;
        file "/etc/bind/db.192";
      };"
    )
  end

  before do
    use_case.call(config)
  end

  it "publishes the BIND config" do
    expect(s3_gateway).to have_received(:write)
      .with(data: config)
  end
end
