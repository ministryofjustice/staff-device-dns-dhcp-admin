require "rails_helper"

RSpec.describe UseCases::SaveDhcpDbRecord do
  let(:publish_kea_config) { spy(:publish_kea_config) }
  let(:deploy_dhcp_service) { spy(:deploy_dhcp_service) }
  let(:record) { build(:reservation) }

  subject(:use_case) do
    described_class.new(
      publish_kea_config: publish_kea_config,
      deploy_dhcp_service: deploy_dhcp_service
    )
  end

  describe "#call" do
    context "when the record is saved" do
      it "saves the record" do
        use_case.call(record)
        expect(record).to be_persisted
      end

      it "publishes the kea config" do
        use_case.call(record)
        expect(publish_kea_config).to have_received(:call)
      end

      it "deploys the dhcp service" do
        use_case.call(record)
        expect(deploy_dhcp_service).to have_received(:call)
      end

      it "returns true" do
        result = use_case.call(record)
        expect(result).to eql(true)
      end
    end

    context "when the record fails to save" do
      before do
        allow(record).to receive(:valid?).and_return(false)
      end

      it "returns false" do
        result = use_case.call(record)
        expect(result).to eql(false)
      end
    end
  end
end