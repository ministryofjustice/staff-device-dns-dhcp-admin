require "rails_helper"

describe Gateways::BindVerifier do
  subject { described_class.new }

  describe "#verify_config" do
    context "when the config is valid" do
      let(:generated_config) { UseCases::GenerateBindConfig.new(zones: [], pdns_ips: "7.7.7.7,5.5.5.5").call }

      it "returns successfully" do
        expect(subject.verify_config(generated_config)).to eq(true)
      end

      context "when the config is an empty string" do
        let(:config) { "" }

        it "raises a EmptyConfigError" do
          expect { subject.verify_config(config) }
            .to raise_error(described_class::EmptyConfigError, "Some configuration options must be specified")
        end
      end

      context "when the config is invalid" do
        let(:config) { "This can be anything" }

        it "raises a ConfigurationError" do
          expect { subject.verify_config(config) }
            .to raise_error(described_class::ConfigurationError)
        end
      end
    end
  end
end
