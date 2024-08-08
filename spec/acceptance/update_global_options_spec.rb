require "rails_helper"

describe "update global options", type: :feature do
  let(:global_option) do
    Audited.audit_class.as_user(User.first) do
      create(:global_option)
    end
  end

  context "when a user is not logged in" do
    it "it does not allow editing global options" do
      visit "/global-options/#{global_option.id}/edit"

      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end

  context "when a user is logged in as an viewer" do
    before do
      login_as create(:user, :viewer)
    end

    it "does not allow editing global options" do
      visit "/global-options"

      expect(page).not_to have_content("Edit global option")

      visit "/global-options/#{global_option.id}/edit"

      expect(page).to have_content("You are not authorized to access this page.")
    end
  end

  context "when a user is logged in as an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
      global_option
    end

    it "edits an existing global option" do
      visit "/global-options"

      expect(page).not_to have_content("Create global options")
      click_on "Edit global option"

      expect(page).to have_field("Domain name servers", with: global_option.domain_name_servers.join(","))
      expect(page).to have_field("Domain name", with: global_option.domain_name)

      fill_in "Domain name servers", with: "10.0.2.2,10.0.2.3"
      fill_in "Domain name", with: "testier.example.com"

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Update"

      expect(page).to have_content("Successfully updated global option")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("10.0.2.2,10.0.2.3")
      expect(page).to have_content("testier.example.com")

      expect_audit_log_entry_for(editor.email, "update", "Global option")
    end

    it "displays validation errors if the record fails to save" do
      visit "/global-options/#{global_option.to_param}/edit"

      fill_in "Domain name", with: ""

      click_on "Update"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "Domain name can't be blank"
    end

    it "displays dhcp config verification errors" do
      visit "/global-options/#{global_option.to_param}/edit"

      allow_config_verification_to_fail_with_message("this isnt what kea looks like :(")

      click_on "Update"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "this isnt what kea looks like :("
    end
  end
end
