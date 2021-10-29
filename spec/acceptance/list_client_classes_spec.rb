require "rails_helper"

RSpec.describe "Listing Client Classes", type: :feature do
  context "when a user is not logged in" do
    it "it does not allow editing the client class" do
      visit "/client-classes"

      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end

  context "when a user is logged in as an reader" do
    let!(:client_class) { create :client_class }
    let!(:client_class2) { create :client_class }

    before do
      login_as create(:user, :viewer)
    end

    it "displays a list of client classes" do
      visit "/dhcp"

      click_on "Client classes"

      expect(page).to have_content client_class.name
      expect(page).to have_content client_class2.name
    end
  end
end
