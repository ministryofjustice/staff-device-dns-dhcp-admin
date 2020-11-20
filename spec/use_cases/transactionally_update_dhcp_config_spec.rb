require "rails_helper"

RSpec.describe UseCases::TransactionallyUpdateDhcpConfig do
  let(:generate_kea_config) { spy(:generate_kea_config) }
  let(:verify_kea_config) { spy(:verify_kea_config) }
  let(:publish_kea_config) { spy(:publish_kea_config) }
  let(:deploy_dhcp_service) { spy(:deploy_dhcp_service) }
  let(:record) { build(:reservation) }
  let(:operation) { -> { record.save } }

  subject(:use_case) do
    described_class.new(
      generate_kea_config: generate_kea_config,
      verify_kea_config: verify_kea_config,
      publish_kea_config: publish_kea_config,
      deploy_dhcp_service: deploy_dhcp_service
    )
  end

  describe "#call" do
    context "when the operation is saved" do
      it "saves the operation" do
        use_case.call(record, operation)
        expect(record).to be_persisted
      end

      it "generates the kea config" do
        use_case.call(record, operation)
        expect(generate_kea_config).to have_received(:call)
      end

      it "verifies the kea config" do
        use_case.call(record, operation)
        expect(verify_kea_config).to have_received(:call)
      end

      it "publishes the kea config" do
        use_case.call(record, operation)
        expect(publish_kea_config).to have_received(:call)
      end

      it "deploys the dhcp service" do
        use_case.call(record, operation)
        expect(deploy_dhcp_service).to have_received(:call)
      end

      it "returns true" do
        result = use_case.call(record, operation)
        expect(result).to eql(true)
      end
    end

    context "when the operation fails to save" do
      before do
        allow(record).to receive(:valid?).and_return(false)
      end

      it "returns false" do
        result = use_case.call(record, operation)
        expect(result).to eql(false)
      end
    end

    context "when the kea config is invalid" do
      before do
        allow(verify_kea_config).to receive(:call).and_return(false)
      end

      it "adds errors to the record" do
        use_case.call(record, operation)
        expect(record.errors[:base]).not_to be_empty
      end
    end
  end
end
