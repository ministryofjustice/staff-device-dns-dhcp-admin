require "rails_helper"

describe "update sites", type: :feature do
  let!(:site) { create(:site) }

  context "when the user is a unauthenticated" do
    it "does not allow creating sites" do
      visit "/sites/#{site.to_param}/edit"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as User.create!(editor: false)
    end

    it "does not allow editing sites" do
      visit "/sites"

      expect(page).not_to have_content "Edit"

      visit "/sites/#{site.to_param}/edit"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    before do
      login_as User.create!(editor: true)
    end

    it "update an existing site" do
      visit "/sites"

      click_on "Edit"

      expect(page).to have_field("FITS ID", with: site.fits_id)
      expect(page).to have_field("Name", with: site.name)

      fill_in "FITS ID", with: "MYFITS202"
      fill_in "Name", with: "My Manchester Site"

      click_on "Update"

      expect(current_path).to eq("/sites")

      expect(page).to have_content("MYFITS202")
      expect(page).to have_content("My Manchester Site")
    end
  end
end
