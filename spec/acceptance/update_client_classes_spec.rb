require "rails_helper"

describe "update client class", type: :feature do
  let(:client_class) do
    Audited.audit_class.as_user(User.first) do
      create(:client_class)
    end
  end

  context "when a user is not logged in" do
    it "it does not allow editing client class" do
      visit "/client-classes/#{client_class.id}/edit"

      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end

  context "when a user is logged in as an viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing client class" do
      visit "/client-classes"

      expect(page).not_to have_content("Edit")

      visit "/client-classes/#{client_class.id}/edit"

      expect(page).to have_content("You are not authorized to access this page.")
    end
  end

  context "when a user is logged in as an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
      client_class
    end

    it "edits an existing client class" do
      visit "/client-classes"

      click_on "Manage"

      expect(page).to have_field("Name", with: client_class.name)
      expect(page).to have_field("Client id", with: client_class.client_id)
      expect(page).to have_field("Domain name servers", with: client_class.domain_name_servers.join(","))
      expect(page).to have_field("Domain name", with: client_class.domain_name)

      fill_in "Name", with: "usr15_device"
      fill_in "Client id", with: "A20YYQ-123"
      fill_in "Domain name servers", with: "10.0.2.3,10.0.2.4"
      fill_in "Domain name", with: "tester.example.com"

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Update"

      expect(page).to have_content("Successfully updated client class")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("usr15_device")
      expect(page).to have_content("A20YYQ-123")
      expect(page).to have_content("10.0.2.3,10.0.2.4")
      expect(page).to have_content("tester.example.com")

      expect_audit_log_entry_for(editor.email, "update", "Client class")
    end

    it "displays error if form cannot be submitted" do
      visit "/client-classes/#{client_class.id}/edit"

      fill_in "Name", with: ""

      click_on "Update"

      expect(page).to have_content "There is a problem"
    end
  end
end
