require "rails_helper"

RSpec.describe UseCases::VerifyKeaConfig do
  let(:kea_control_agent_gateway) { instance_double(Gateways::KeaControlAgent) }
  let(:config) { double(:config) }

  subject(:use_case) do
    described_class.new(kea_control_agent_gateway: kea_control_agent_gateway)
  end

  describe "#call" do
    context "when the config is valid" do
      before do
        allow(kea_control_agent_gateway).to receive(:verify_config).and_return({ "result" => 0 })
      end

      it "returns true" do
        expect(use_case.call(config)).to eql(true)
      end
    end

    context "when the config is invalid" do
      before do
        allow(kea_control_agent_gateway).to receive(:verify_config).and_return({ "result" => 1 })
      end

      it "returns false" do
        expect(use_case.call(config)).to eql(false)
      end
    end
  end
end
