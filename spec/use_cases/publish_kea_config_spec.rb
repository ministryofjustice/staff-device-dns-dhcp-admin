require "rails_helper"

describe UseCases::PublishKeaConfig do
  subject(:use_case) do
    described_class.new(
      destination_gateway: s3_gateway
    )
  end

  let(:s3_gateway) { instance_spy(Gateways::S3) }
  let(:config) do
    {some: "json"}
  end

  before do
    use_case.call(config)
  end

  it "publishes the Kea config" do
    expect(s3_gateway).to have_received(:write)
      .with(data: config.to_json)
  end
end
