require "rails_helper"

RSpec.describe UseCases::TransactionallyUpdateDnsConfig do
  let(:generate_bind_config) { spy(:generate_bind_config) }
  let(:verify_bind_config) { spy(:verify_bind_config) }
  let(:publish_bind_config) { spy(:publish_bind_config) }
  let(:deploy_dns_service) { spy(:deploy_dns_service) }
  let(:record) { build(:reservation) }
  let(:operation) { -> { record.save } }

  subject(:use_case) do
    described_class.new(
      generate_bind_config: generate_bind_config,
      verify_bind_config: verify_bind_config,
      publish_bind_config: publish_bind_config,
      deploy_dns_service: deploy_dns_service
    )
  end

  describe "#call" do
    context "when the operation is saved" do
      it "saves the operation" do
        use_case.call(record, operation)
        expect(record).to be_persisted
      end

      it "generates the bind config" do
        use_case.call(record, operation)
        expect(generate_bind_config).to have_received(:call)
      end

      it "verifies the bind config" do
        use_case.call(record, operation)
        expect(verify_bind_config).to have_received(:call)
      end

      it "publishes the bind config" do
        use_case.call(record, operation)
        expect(publish_bind_config).to have_received(:call)
      end

      it "deploys the dns service" do
        use_case.call(record, operation)
        expect(deploy_dns_service).to have_received(:call)
      end

      it "returns true" do
        result = use_case.call(record, operation)
        expect(result).to eql(true)
      end
    end

    context "when the operation fails" do
      before do
        allow(record).to receive(:valid?).and_return(false)
      end

      it "returns false" do
        result = use_case.call(record, operation)
        expect(result).to eql(false)
      end
    end

    context "when the bind config is invalid" do
      let(:result) { double(:result, success?: false, error: StandardError.new("im borked")) }

      before do
        allow(verify_bind_config).to receive(:call).and_return(result)
      end

      it "does not save the record" do
        use_case.call(record, operation)
        expect(record).not_to be_persisted
      end

      xit "adds errors to the record" do
        use_case.call(record, operation)
        expect(record.errors[:base]).to include(result.error.message)
      end
    end
  end
end
