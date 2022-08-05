require 'rails_helper'

RSpec.describe "Errors", type: :feature do
  describe "GET /asdf" do
    it "returns http success" do
      visit "/asdf"
      p page
      expect(page).to have_content("Page not found")
    end
  end

end
