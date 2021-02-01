require "rails_helper"

describe SubnetPresenter do
  describe "#display_valid_lifetime" do
    it "returns a user-friendly valid lifetime unit of 320 seconds" do
      option = build_stubbed(:option, valid_lifetime: 320, valid_lifetime_unit: "Seconds")
      subnet = build_stubbed(:subnet, option: option)

      presenter = SubnetPresenter.new(subnet)

      expect(presenter.display_valid_lifetime).to eq("320 seconds")
    end

    it "returns a user-friendly valid lifetime unit of 1 minute" do
      option = build_stubbed(:option, valid_lifetime: 1, valid_lifetime_unit: "Minutes")
      subnet = build_stubbed(:subnet, option: option)

      presenter = SubnetPresenter.new(subnet)

      expect(presenter.display_valid_lifetime).to eq("1 minute")
    end

    it "returns a user-friendly valid lifetime unit of 26 hours" do
      option = build_stubbed(:option, valid_lifetime: 26, valid_lifetime_unit: "Hours")
      subnet = build_stubbed(:subnet, option: option)

      presenter = SubnetPresenter.new(subnet)

      expect(presenter.display_valid_lifetime).to eq("26 hours")
    end

    it "returns a user-friendly valid lifetime unit of 3 days" do
      option = build_stubbed(:option, valid_lifetime: 3, valid_lifetime_unit: "Days")
      subnet = build_stubbed(:subnet, option: option)

      presenter = SubnetPresenter.new(subnet)

      expect(presenter.display_valid_lifetime).to eq("3 days")
    end
  end
end
