require "rails_helper"

describe Gateways::KeaControlAgent do
  let(:uri) { "http://example.com/" }
  subject { described_class.new(uri: uri) }

  describe "#verify_config" do
    context "when the kea api returns an error" do
      let(:config) { { Dhcp4: {} } }
      let(:kea_response) do
        [{
          "result": 1,
          "text": "thats invalid"
        }].to_json
      end

      before do
        stub_request(:post, uri)
        .with(body: {
          command: "config-test",
          service: ["dhcp4"],
          arguments: config
        }, headers: {
          "Content-Type": "application/json"
        })
        .to_return(body: kea_response)
      end

      it "raises a InternalError" do
        expect { subject.verify_config(config) }
          .to raise_error(described_class::InternalError, "thats invalid")
      end
    end
  end
end
