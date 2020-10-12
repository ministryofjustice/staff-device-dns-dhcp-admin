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
      login_as User.create!(editor: false)
    end

    it "does not allow creating sites" do
      visit "/dhcp"

      expect(page).not_to have_content "Create a new site"

      visit "/sites/new"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    before do
      login_as User.create!(editor: true)
    end

    it "creates a new site" do
      visit "/dhcp"

      click_on "Create a new site"

      expect(current_path).to eql("/sites/new")

      fill_in "FITS ID", with: "MYFITS101"
      fill_in "Name", with: "My London Site"

      click_on "Create"

      expect(current_path).to eq("/dhcp")

      expect(page).to have_content("MYFITS101")
      expect(page).to have_content("My London Site")
    end

    it "displays error if form cannot be submitted" do
      visit "/sites/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
    end
  end
end
