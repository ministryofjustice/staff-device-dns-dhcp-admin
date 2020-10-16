require "rails_helper"

describe OptionPresenter do
  describe "#display_name" do
    it "returns the subnet cidr_block" do
      option = build_stubbed(:option)
      presenter = OptionPresenter.new(option)

      expect(presenter.display_name).to eq(option.subnet.cidr_block)
    end
  end
end
