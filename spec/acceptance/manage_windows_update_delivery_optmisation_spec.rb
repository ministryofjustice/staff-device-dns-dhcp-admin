require "rails_helper"

describe "windows update delivery optmisation", type: :feature do
  let(:site) do
    Audited.audit_class.as_user(User.first) do
      create(:site)
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :viewer)
    end

    it "does not allow editing windows update delivery optmisation" do
      visit "/sites/#{site.to_param}"

      expect(page).not_to have_link "Change name"
      expect(page).not_to have_link "Change FITS id"
      expect(page).not_to have_link "Change Windows update delivery optimisation"
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
      site
    end

    it "enables windows update delivery optimisation for an existing site" do
      visit "/sites/#{site.id}"

      click_on "Change Windows update delivery optimisation"

      expect(page).to have_content("Windows update delivery optimisation")
      expect(page).to have_checked_field("site_windows_update_delivery_optimisation_enabled_false")

      choose("site_windows_update_delivery_optimisation_enabled_true")

      expect(page).to have_checked_field("site_windows_update_delivery_optimisation_enabled_true")

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Update"

      expect(current_path).to eq("/sites/#{site.id}")

      expect(page).to have_text("Windows update delivery optimisation Enabled (uuid: #{site.uuid})")

      expect_audit_log_entry_for(editor.email, "update", "Site")
    end

    it "disables windows update delivery optimisation for an existing site" do
      site.toggle!(:windows_update_delivery_optimisation_enabled)

      visit "/sites/#{site.id}"

      click_on "Change Windows update delivery optimisation"

      expect(page).to have_checked_field("site_windows_update_delivery_optimisation_enabled_true")

      choose("site_windows_update_delivery_optimisation_enabled_false")

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Update"

      expect(page).to have_text("Windows update delivery optimisation Disabled")
    end
  end
end
