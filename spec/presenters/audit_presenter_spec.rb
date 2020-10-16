require "rails_helper"

describe AuditPresenter do
  describe "#name" do
    it "returns the auditable type if the auditable is nil (i.e deleted)" do
      audit = double(auditable_type: "Site", auditable: nil)
      presenter = AuditPresenter.new(audit)

      expect(presenter.name).to eq("Site")
    end

    it "appends the display name of the auditable presenter to the auditable type" do
      auditable = build_stubbed(:subnet, cidr_block: "10.0.0.1/23")
      audit = double(auditable_type: "Subnet", auditable: auditable)
      presenter = AuditPresenter.new(audit)

      expect(presenter.name).to eq("Subnet (10.0.0.1/23)")
    end

    it "does not use the auditable display name if it is blank" do
      auditable = build_stubbed(:global_option)
      audit = double(auditable_type: "GlobalOption", auditable: auditable)
      presenter = AuditPresenter.new(audit)

      expect(presenter.name).to eq("Global option")
    end
  end
end
