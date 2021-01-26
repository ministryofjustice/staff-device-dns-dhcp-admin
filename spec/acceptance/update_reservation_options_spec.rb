require "rails_helper"

describe "update reservation options", type: :feature do
  let(:reservation_option) do
    Audited.audit_class.as_user(User.first) do
      create(:reservation_option)
    end
  end

  let(:reservation) { reservation_option.reservation }

  context "when a user is not logged in" do
    it "it does not allow editing reservation options" do
      visit "/reservation_options/#{reservation_option.to_param}/edit"

      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end

  context "when a user is logged in as an viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing reservation options" do
      visit "/reservations/#{reservation.to_param}"

      expect(page).not_to have_content("Edit")

      visit "/reservation_options/#{reservation_option.to_param}/edit"

      expect(page).to have_content("You are not authorized to access this page.")
    end
  end

  context "when a user is logged in as an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "edits an existing reservation option" do
      visit "/reservations/#{reservation.to_param}"

      expect(page).not_to have_content("Create reservation options")
      click_on "Manage"

      expect(page).to have_field("Routers", with: reservation_option.routers.join(","))
      expect(page).to have_field("Domain name", with: reservation_option.domain_name)

      fill_in "Routers", with: "10.0.1.1,10.0.1.100"
      fill_in "Domain name", with: "testing.example.com"

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Update"

      expect(page).to have_content("Successfully updated reservation options")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("10.0.1.1,10.0.1.100")
      expect(page).to have_content("testing.example.com")

      expect_audit_log_entry_for(editor.email, "update", "Reservation option")
    end

    it "displays error if form cannot be submitted" do
      visit "/reservation_options/#{reservation_option.to_param}/edit"

      fill_in "Routers", with: ""
      fill_in "Domain name", with: ""

      click_on "Update"

      expect(page).to have_content "There is a problem"
    end
  end
end
