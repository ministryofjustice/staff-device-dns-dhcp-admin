require "rails_helper"

describe "create global options", type: :feature do
  context "when a user is not logged in" do
    it "it does not allow editing global_options" do
      visit "/global-options/new"

      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end

  context "when a user is logged in as an viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing global options" do
      visit "/global-options"

      expect(page).not_to have_content("Create global options")

      visit "/global-options/new"

      expect(page).to have_content("You are not authorized to access this page.")
    end
  end

  context "when a user is logged in as an editor" do
    let(:editor) { create :user, :editor }

    before do
      login_as editor
    end

    it "creates a new global option" do
      visit "/global-options"

      click_on "Create global options"

      fill_in "Routers", with: "10.0.1.0,10.0.1.2"
      fill_in "Domain name servers", with: "10.0.2.1,10.0.2.2"
      fill_in "Domain name", with: "test.example.com"
      fill_in "Valid lifetime", with: 12345

      click_on "Create"

      expect(page).to have_content("Successfully created global option")
      expect(page).to have_content("10.0.1.0,10.0.1.2")
      expect(page).to have_content("10.0.2.1,10.0.2.2")
      expect(page).to have_content("test.example.com")
      expect(page).to have_content("12345")

      click_on "Audit log"

      expect(page).to have_content(editor.email)
      expect(page).to have_content("create")
      expect(page).to have_content("Global option")
    end

    it "displays error if form cannot be submitted" do
      visit "/global-options/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
    end
  end
end
