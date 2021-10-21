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

    it "displays validations errors if form cannot be submitted" do
      visit "/reservations/#{reservation.to_param}/options/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "At least one option must be filled out"
    end

    it "displays dhcp config verification errors" do
      visit "/reservations/#{reservation.to_param}/options/new"

      when_i_fill_in_the_form_with_valid_data

      allow_config_verification_to_fail_with_message("this isnt what kea looks like :(")

      click_on "Create"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "this isnt what kea looks like :("
    end   
  end

  def when_i_fill_in_the_form_with_valid_data
    fill_in "Routers", with: "10.0.1.0,10.0.1.2"
    fill_in "Domain name", with: "sub.domain.my-example.com"
  end
end
