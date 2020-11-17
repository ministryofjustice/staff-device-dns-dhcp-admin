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
      login_as create(:user, :reader)
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
      visit "/dhcp"

      click_on "Edit"

      expect(page).to have_field("FITS id", with: site.fits_id)
      expect(page).to have_field("Name", with: site.name)

      fill_in "FITS id", with: "MYFITS202"
      fill_in "Name", with: "My Manchester Site"

      expect_config_to_be_verified
      expect_config_to_be_published
      expect_service_to_be_rebooted

      click_on "Update"

      expect(current_path).to eq("/dhcp")

      expect(page).to have_content("MYFITS202")
      expect(page).to have_content("My Manchester Site")

      expect_audit_log_entry_for(editor.email, "update", "Site")
    end
  end
end
