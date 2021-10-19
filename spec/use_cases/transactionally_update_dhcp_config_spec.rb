require "rails_helper"

RSpec.describe UseCases::TransactionallyUpdateDhcpConfig do
  let(:generate_kea_config) { spy(:generate_kea_config) }
  let(:verify_kea_config) { spy(:verify_kea_config) }
  let(:publish_kea_config) { spy(:publish_kea_config) }
  let(:record) { build(:reservation) }
  let(:operation) { -> { record.save } }

  subject(:use_case) do
    described_class.new(
      generate_kea_config: generate_kea_config,
      verify_kea_config: verify_kea_config,
      publish_kea_config: publish_kea_config
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

      it "returns a successful result" do
        result = use_case.call(record, operation)
        expect(result.success?).to eql(true)
      end
    end

    context "when the operation fails" do
      before do
        allow(record).to receive(:valid?).and_return(false)
      end

      it "returns an unsuccessful result" do
        result = use_case.call(record, operation)
        expect(result.success?).to eql(false)
      end
    end

    context "when the kea config fails verification" do
      before do
        allow(verify_kea_config).to receive(:call).and_return(
          UseCases::Result.new(StandardError.new("im borked"))
        )
      end

      it "does not save the record" do
        use_case.call(record, operation)
        expect(record).not_to be_persisted
      end

      it "adds errors to the result" do
        result = use_case.call(record, operation)
        expect(result.errors.full_messages).to include("im borked")
      end
    end
  end
end
