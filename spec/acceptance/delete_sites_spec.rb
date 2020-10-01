require "rails_helper"

describe "delete sites", type: :feature do
  context "when the user is a viewer" do
    before do
      login_as User.create!(editor: false)
    end

    it "does not allow creating sites" do
      visit "/sites"

      expect(page).not_to have_content "Delete"
    end
  end

  context "when the user is an editor" do
    before do
      login_as User.create!(editor: true)
    end

    it "delete a site" do
      site = create(:site)

      visit "/sites"

      click_on "Delete"

      expect(page).to have_content("Are you sure you want to delete this site?")

      click_on "Delete site"

      expect(current_path).to eq("/sites")
      expect(page).to have_content("Successfully deleted site")
      expect(page).not_to have_content(site.name)
    end
  end
end
