require "rails_helper"

describe GlobalOptionPresenter do
  describe "#display_valid_lifetime" do
    it "returns a user-friendly valid lifetime unit of 320 second'" do
      global_option = build_stubbed(:global_option, valid_lifetime: 320, valid_lifetime_unit: "Seconds")
      presenter = GlobalOptionPresenter.new(global_option)

      expect(presenter.display_valid_lifetime).to eq("320 seconds")
    end

    it "returns a user-friendly valid lifetime unit of 1 minute" do
      global_option = build_stubbed(:global_option, valid_lifetime: 1, valid_lifetime_unit: "Minutes")
      presenter = GlobalOptionPresenter.new(global_option)

      expect(presenter.display_valid_lifetime).to eq("1 minute")
    end

    it "returns a user-friendly valid lifetime unit of 26 hours" do
      global_option = build_stubbed(:global_option, valid_lifetime: 26, valid_lifetime_unit: "Hours")
      presenter = GlobalOptionPresenter.new(global_option)

      expect(presenter.display_valid_lifetime).to eq("26 hours")
    end

    it "returns a user-friendly valid lifetime unit of 3 days" do
      global_option = build_stubbed(:global_option, valid_lifetime: 3, valid_lifetime_unit: "Days")
      presenter = GlobalOptionPresenter.new(global_option)

      expect(presenter.display_valid_lifetime).to eq("3 days")
    end
  end
end
