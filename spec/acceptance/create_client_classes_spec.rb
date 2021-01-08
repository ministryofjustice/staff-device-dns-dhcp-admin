require "rails_helper"

describe "create client class", type: :feature do
  context "when a user is not logged in" do
    it "it does not allow editing the client class" do
      visit "/client-classes/new"

      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end

  context "when a user is logged in as an viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing client class" do
      visit "/client-classes"

      expect(page).not_to have_content("Create client class")

      visit "/client-classes/new"

      expect(page).to have_content("You are not authorized to access this page.")
    end
  end

  context "when a user is logged in as an editor" do
    let(:editor) { create :user, :editor }

    before do
      login_as editor
    end

    it "creates a new client class" do
      visit "/client-classes"

      click_on "Create client class"

      fill_in "Name", with: "usr1_device"
      fill_in "Client id", with: "A20YYQ"
      fill_in "Domain name servers", with: "10.0.2.1,10.0.2.2"
      fill_in "Domain name", with: "test.example.com"

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Create"

      expect(page).to have_content("Successfully created client class")
      expect(page).to have_content("usr1_device")
      expect(page).to have_content("A20YYQ")
      expect(page).to have_content("10.0.2.1,10.0.2.2")
      expect(page).to have_content("test.example.com")

      expect_audit_log_entry_for(editor.email, "create", "Client class")
    end

    it "displays error if form cannot be submitted" do
      visit "/client-classes/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
    end
  end
end
