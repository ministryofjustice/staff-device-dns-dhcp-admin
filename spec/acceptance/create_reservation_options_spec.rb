require "rails_helper"

describe "create reservation options", type: :feature do
  let(:reservation) do
    Audited.audit_class.as_user(User.first) do
      create(:reservation)
    end
  end

  context "when a user is not logged in" do
    it "it does not allow editing reservation options" do
      visit "/reservations/#{reservation.to_param}/reservation_options/new"

      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end

  context "when a user is logged in as an viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing reservation options" do
      visit "/subnets/#{reservation.subnet.to_param}"

      expect(page).not_to have_content("Create reservation options")

      visit "/reservations/#{reservation.to_param}/reservation_options/new"

      expect(page).to have_content("You are not authorized to access this page.")
    end
  end

  context "when a user is logged in as an editor" do
    let(:editor) { create :user, :editor }

    before do
      login_as editor
    end

    it "creates a new reservation option" do
      visit "/subnets/#{reservation.subnet.to_param}"
      
      expect(page).not_to have_content("Edit reservation options")
      click_on "Create reservation options"
      visit "/reservations/#{reservation.to_param}/reservation_options/new"

      fill_in "Routers", with: "10.0.1.0,10.0.1.2"
      fill_in "Domain name", with: "test.example.com"

      # expect_config_to_be_published
      # expect_service_to_be_rebooted

      click_on "Create"

      expect(page).to have_content("Successfully created reservation options")
      expect(page).to have_content("10.0.1.0,10.0.1.2")
      expect(page).to have_content("test.example.com")

      # expect_audit_log_entry_for(editor.email, "create", "ReservationOption")
    end

    it "displays error if form cannot be submitted" do
      visit "/reservations/#{reservation.to_param}/reservation_options/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
    end
  end
end
