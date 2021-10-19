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
        allow(kea_control_agent_gateway).to receive(:verify_config)
      end

      it "returns a successful result" do
        expect(use_case.call(config).success?).to eql(true)
      end
    end

    context "when the config is invalid" do
      let(:error) { Gateways::KeaControlAgent::InternalError.new("oh noes!") }

      before do
        allow(kea_control_agent_gateway).to receive(:verify_config).and_raise(error)
      end

      it "returns an unsuccessful result" do
        expect(use_case.call(config).success?).to eql(false)
      end

      it "returns the result error" do
        expect(use_case.call(config).errors.full_messages).to include(error.message)
      end
    end
  end
end
