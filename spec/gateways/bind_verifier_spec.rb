require "rails_helper"

describe Gateways::BindVerifier do
  subject { described_class.new }
  
  describe "#verify_config" do
    context "when the calling bind verify" do
      let(:generated_config) { UseCases::GenerateBindConfig.new(zones: [], pdns_ips: "7.7.7.7,5.5.5.5").call }
      
      it "returns successfully" do
        expect { subject.verify_config(generated_config) }.to eq("success")
      end

      context "when the verify bind config returns an error" do
        let(:config) { "This can be anything" }

        it "raises a InternalError" do
          expect { subject.verify_config(config) }
            .to raise_error(described_class::InternalError, "thats invalid")
        end
      end
    end
  end
end
