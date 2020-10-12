require "rails_helper"

describe "update global options", type: :feature do
  let(:global_option) { create(:global_option) }

  context "when a user is not logged in" do
    it "it does not allow editing global options" do
      visit "/global-options/#{global_option.id}/edit"

      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end

  context "when a user is logged in as an viewer" do
    before do
      login_as User.create!(editor: false)
    end

    it "does not allow editing global options" do
      visit "/global-options"

      expect(page).not_to have_content("Edit global option")

      visit "/global-options/#{global_option.id}/edit"

      expect(page).to have_content("You are not authorized to access this page.")
    end
  end

  context "when a user is logged in as an editor" do
    before do
      login_as User.create!(editor: true)
      global_option
    end

    it "edits an existing global option" do
      visit "/global-options"

      expect(page).not_to have_content("Create global options")
      click_on "Edit global option"

      expect(page).to have_field("Routers", with: global_option.routers.join(","))
      expect(page).to have_field("Domain name servers", with: global_option.domain_name_servers.join(","))
      expect(page).to have_field("Domain name", with: global_option.domain_name)

      fill_in "Routers", with: "10.0.1.1,10.0.1.3"
      fill_in "Domain name servers", with: "10.0.2.2,10.0.2.3"
      fill_in "Domain name", with: "testier.example.com"

      click_on "Update"

      expect(page).to have_content("Successfully updated global option")
      expect(page).to have_content("10.0.1.1,10.0.1.3")
      expect(page).to have_content("10.0.2.2,10.0.2.3")
      expect(page).to have_content("testier.example.com")
    end

    it "displays error if form cannot be submitted" do
      visit "/global-options/#{global_option.id}/edit"

      fill_in "Routers", with: ""

      click_on "Update"

      expect(page).to have_content "There is a problem"
    end
  end
end
