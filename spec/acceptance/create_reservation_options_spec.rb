require "rails_helper"

describe "create reservation options", type: :feature do
  let(:reservation) do
    Audited.audit_class.as_user(User.first) do
      create(:reservation)
    end
  end

  context "when a user is not logged in" do
    it "it does not allow editing reservation options" do
      visit "/reservations/#{reservation.to_param}/options/new"

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

      visit "/reservations/#{reservation.to_param}/options/new"

      expect(page).to have_content("You are not authorized to access this page.")
    end
  end

  context "when a user is logged in as an editor" do
    let(:editor) { create :user, :editor }

    before do
      login_as editor
    end

    it "creates a new reservation option" do
      visit "/reservations/#{reservation.to_param}"

      expect(page).not_to have_content("Edit")

      click_on "Create reservation options"

      fill_in "Routers", with: "10.0.1.0,10.0.1.2"
      fill_in "Domain name", with: "sub.domain.my-example.com"

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Create"

      expect(page).to have_content("Successfully created reservation options")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("10.0.1.0,10.0.1.2")
      expect(page).to have_content("sub.domain.my-example.com")

      expect_audit_log_entry_for(editor.email, "create", "Reservation option")
    end

    it "displays error if form cannot be submitted" do
      visit "/reservations/#{reservation.to_param}/options/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
    end

    it "displays error if domain name invalid" do
      visit "/reservations/#{reservation.to_param}"

      expect(page).not_to have_content("Edit")

      click_on "Create reservation options"

      fill_in "Routers", with: "10.0.1.0,10.0.1.2"
      fill_in "Domain name", with: "me.example/.co"

      click_on "Create"

      expect(page).to have_content("There is a problem")
    end
  end
end
