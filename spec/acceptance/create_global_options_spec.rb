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

      fill_in "Domain name servers", with: "10.0.2.1,10.0.2.2"
      fill_in "Domain name", with: "test.example.com"
      fill_in "Valid lifetime", with: 12345
      select "Minutes", from: "global_option[valid_lifetime_unit]"

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Create"

      expect(page).to have_content("Successfully created global option")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("10.0.2.1,10.0.2.2")
      expect(page).to have_content("test.example.com")
      expect(page).to have_content("12345 minutes")

      expect_audit_log_entry_for(editor.email, "create", "Global option")
    end

    it "Edit global options to have a valid lifetime of 1 hour" do
      visit "/global-options"

      click_on "Create global options"

      when_i_fill_in_the_form_with_valid_data

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Create"

      expect(page).to have_content("1 hour")

      expect_audit_log_entry_for(editor.email, "create", "Global option")
    end

    it "displays validation errors if the record fails to save" do
      visit "/global-options/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "Domain name can't be blank"
    end

    it "displays dhcp config verification errors" do
      visit "/global-options/new"

      when_i_fill_in_the_form_with_valid_data

      allow_config_verification_to_fail_with_message("this isnt what kea looks like :(")

      click_on "Create"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "this isnt what kea looks like :("
    end
  end

  def when_i_fill_in_the_form_with_valid_data
    fill_in "Domain name servers", with: "10.0.2.10,10.0.2.20"
    fill_in "Domain name", with: "test2.example.com"
    fill_in "Valid lifetime", with: 1
    select "Hours", from: "global_option[valid_lifetime_unit]"
  end
end
