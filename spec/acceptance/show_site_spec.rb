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
      let!(:subnet) { create :subnet, site: site }
      let!(:subnet2) { create :subnet, site: site }
      let!(:subnet3) { create :subnet }

      it "allows viewing sites and its subnets" do
        visit "/sites"

        click_on site.fits_id

        expect(page).to have_content site.fits_id
        expect(page).to have_content site.name

        expect(page).to have_content subnet.cidr_block
        expect(page).to have_content subnet.start_address
        expect(page).to have_content subnet.end_address

        expect(page).to have_content subnet2.cidr_block

        expect(page).not_to have_content subnet3.cidr_block
      end
    end
  end
end
