require "rails_helper"

describe "delete sites", type: :feature do
  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow creating sites" do
      visit "/dhcp"

      expect(page).not_to have_content "Delete"
    end
  end

  context "when the user is an editor" do
    let!(:site) do
      Audited.audit_class.as_user(editor) do
        create(:site, :with_subnet)
      end
    end

    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "delete a site" do
      visit "/dhcp"

      click_on "Delete"

      expect(page).to have_content("Are you sure you want to delete this site?")

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Delete site"

      expect(current_path).to eq("/dhcp")
      expect(page).to have_content("Successfully deleted site")
      expect(page).not_to have_content(site.name)

      expect_audit_log_entry_for(editor.email, "destroy", "Site")
    end
  end
end
