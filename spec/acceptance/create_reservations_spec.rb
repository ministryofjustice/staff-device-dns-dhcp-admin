require "rails_helper"

describe "create reservations", type: :feature do
  let(:reservation) do
    Audited.audit_class.as_user(User.first) do
      create(:reservation)
    end
  end

  context "when a user is not logged in" do
    it "it does not allow editing reservations" do
      visit "/subnets/#{reservation.subnet_id}/reservations/new"

      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end

  context "when a user is logged in as a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing reservations" do
      visit "/subnets/#{reservation.subnet_id}"

      expect(page).not_to have_content("Create a new reservation")

      visit "/subnets/#{reservation.subnet_id}/reservations/new"

      expect(page).to have_content("You are not authorized to access this page.")
    end
  end

  context "when a user is logged in as an editor" do
    let(:editor) { create :user, :editor }

    before do
      login_as editor
    end

    it "creates a new subnet reservation" do
      visit "/subnets/#{reservation.subnet_id}"

      click_on "Create a new reservation"

      fill_in "HW address", with: "01:bb:cc:dd:ee:fe"
      fill_in "IP address", with: "192.0.2.2"
      fill_in "Hostname", with: "test.example2.com"
      fill_in "Description", with: "Test reservation"

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Create"

      expect(page).to have_content("Successfully created reservation")
      expect(page).to have_content("01:bb:cc:dd:ee:fe")
      expect(page).to have_content("192.0.2.2")
      expect(page).to have_content("test.example2.com")
      expect(page).to have_content("Test reservation")

      expect_audit_log_entry_for(editor.email, "create", "Reservation")
    end

    it "displays error if form cannot be submitted" do
      visit "/subnets/#{reservation.subnet_id}/reservations/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
    end
  end
end
