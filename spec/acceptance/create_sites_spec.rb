require "rails_helper"

describe "create sites", type: :feature do
  context "when the user is a unauthenticated" do
    it "does not allow creating sites" do
      visit "/sites/new"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :viewer)
    end

    it "does not allow creating sites" do
      visit "/dhcp"

      expect(page).not_to have_content "Create a new site"

      visit "/sites/new"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "creates a new site" do
      visit "/dhcp"

      click_on "Create a new site"

      expect(current_path).to eql("/sites/new")

      when_i_fill_in_the_form_with_valid_data

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Create"

      expect(page).to have_content("Successfully created site.")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("MYFITS101")
      expect(page).to have_content("My London Site")

      expect_audit_log_entry_for(editor.email, "create", "Site")
    end

    it "displays validation errors if form cannot be submitted" do
      visit "/sites/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "FITS id can't be blank"
    end

    it "displays dhcp config verification errors" do
      visit "/sites/new"

      when_i_fill_in_the_form_with_valid_data

      allow_config_verification_to_fail_with_message("this isnt what kea looks like :(")

      click_on "Create"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "this isnt what kea looks like :("
    end
  end

  def when_i_fill_in_the_form_with_valid_data
    fill_in "FITS id", with: "MYFITS101"
    fill_in "Name", with: "My London Site"
  end
end
