require "rails_helper"

RSpec.describe UseCases::VerifyBindConfig do
  let(:bind_verifier_gateway) { instance_double(Gateways::BindVerifier) }
  let(:config) { double(:config) }

  subject(:use_case) do
    described_class.new(bind_verifier_gateway: bind_verifier_gateway)
  end

  describe "#call" do
    context "when the config is valid" do
      before do
        allow(bind_verifier_gateway).to receive(:verify_config)
      end

      it "returns a successful result" do
        expect(use_case.call(config).success?).to eql(true)
      end
    end

    context "when the config is invalid" do
      let(:error) { Gateways::BindVerifier::InternalError.new("oh noes!") }

      before do
        allow(bind_verifier_gateway).to receive(:verify_config).and_raise(error)
      end

      it "returns an unsuccessful result" do
        expect(use_case.call(config).success?).to eql(false)
      end

      it "returns the result error" do
        expect(use_case.call(config).error).to eql(error)
      end
    end
  end
end
