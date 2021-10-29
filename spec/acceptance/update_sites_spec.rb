require "rails_helper"

describe "update sites", type: :feature do
  let(:site) do
    Audited.audit_class.as_user(User.first) do
      create(:site)
    end
  end

  context "when the user is a unauthenticated" do
    it "does not allow creating sites" do
      visit "/sites/#{site.to_param}/edit"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :viewer)
    end

    it "does not allow editing sites" do
      visit "/dhcp"

      expect(page).not_to have_content "Edit"

      visit "/sites/#{site.to_param}/edit"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
      site
    end

    it "update an existing site" do
      visit "/sites/#{site.id}"

      first(:link, "Change").click

      expect(page).to have_field("FITS id", with: site.fits_id)
      expect(page).to have_field("Name", with: site.name)

      fill_in "FITS id", with: "MYFITS202"
      fill_in "Name", with: "My Manchester Site"

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Update"

      expect(current_path).to eq("/sites/#{site.id}")

      expect(page).to have_content("MYFITS202")
      expect(page).to have_content("My Manchester Site")
      expect(page).to have_content("Successfully updated site.")
      expect(page).to have_content("This could take up to 10 minutes to apply.")

      expect_audit_log_entry_for(editor.email, "update", "Site")
    end

    it "displays validation errors if form cannot be submitted" do
      visit "/sites/#{site.id}/edit"

      fill_in "FITS id", with: ""
      click_on "Update"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "FITS id can't be blank"
    end

    it "displays dhcp config verification errors" do
      visit "/sites/#{site.id}/edit"

      allow_config_verification_to_fail_with_message("this isnt what kea looks like :(")

      click_on "Update"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "this isnt what kea looks like :("
    end  
  end
end
