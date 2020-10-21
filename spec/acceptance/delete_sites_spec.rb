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
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "delete a site" do
      site = create(:site)

      visit "/dhcp"

      click_on "Delete"

      expect(page).to have_content("Are you sure you want to delete this site?")

      click_on "Delete site"

      expect(current_path).to eq("/dhcp")
      expect(page).to have_content("Successfully deleted site")
      expect(page).not_to have_content(site.name)

      click_on "Audit log"

      expect(page).to have_content(editor.id.to_s)
      expect(page).to have_content("destroy")
      expect(page).to have_content("Site")
    end
  end
end
