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

      fill_in "HW address", with: "01:bb:cc:dd:ee:ff"
      fill_in "IP address", with: "192.0.2.1"
      fill_in "Hostname", with: "test.example.com"
      fill_in "Description", with: "Test reservation"

      # expect_config_to_be_published
      # expect_service_to_be_rebooted

      click_on "Create"

      expect(page).to have_content("Successfully created reservation")
      expect(page).to have_content("01:bb:cc:dd:ee:ff")
      expect(page).to have_content("192.0.2.1")
      expect(page).to have_content("test.example.com")
      expect(page).to have_content("Test reservation")

      expect_audit_log_entry_for(editor.email, "create", "Reservation")
    end

    it "displays error if form cannot be submitted" do
      visit "/subnets/#{reservation.subnet_id}/reservations/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
    end

    it "handles whitespace in reservation form" do
      visit "/subnets/#{reservation.subnet_id}"

      click_on "Create a new reservation"

      fill_in "HW address", with: " 1a:1b:1c:1d:1e:1f "
      fill_in "IP address", with: " 192.0.2.2 "
      fill_in "Hostname", with: " test.example.com "
      fill_in "Description", with: "Test reservation"

      # expect_config_to_be_published
      # expect_service_to_be_rebooted

      click_on "Create"

      expect(page).to have_content("Successfully created reservation")
      expect(page).to have_content("1a:1b:1c:1d:1e:1f")
      expect(page).to have_content("192.0.2.2")
      expect(page).to have_content("test.example.com")
      expect(page).to have_content("Test reservation")

      # click_on "Audit log"

      # expect(page).to have_content(editor.email)
      # expect(page).to have_content("create")
      # expect(page).to have_content("Option")
    end
  end
end
