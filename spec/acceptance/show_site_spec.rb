require "rails_helper"

describe "showing a site", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing sites" do
      visit "/sites/nonexistant-site-id"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is authenticated" do
    before do
      login_as User.create!
    end

    context "when the site exists" do
      let!(:site) { create :site }

      it "allows viewing sites" do
        visit "/sites"

        click_on site.fits_id

        expect(page).to have_content site.fits_id
        expect(page).to have_content site.name
      end
    end
  end
end
