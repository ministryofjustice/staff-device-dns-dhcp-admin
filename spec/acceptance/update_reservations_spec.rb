require "rails_helper"

describe "update reservations", type: :feature do
  let(:reservation) do
    Audited.audit_class.as_user(User.first) do
      create(:reservation)
    end
  end

  let(:subnet) { reservation.subnet }

  context "when a user is not logged in" do
    it "it does not allow editing reservations" do
      visit "/reservations/#{reservation.id}/edit"

      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end

  context "when a user is logged in as an viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing reservations" do
      visit "/subnets/#{subnet.to_param}"

      expect(page).not_to have_content("Edit reservations")

      visit "/reservations/#{reservation.id}/edit"

      expect(page).to have_content("You are not authorized to access this page.")
    end
  end

  context "when a user is logged in as an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "edits an existing reservation" do
      visit "/subnets/#{subnet.to_param}"

      click_on "Edit"

      expect(page).to have_field("HW address", with: reservation.hw_address)
      expect(page).to have_field("IP address", with: reservation.ip_address)
      expect(page).to have_field("Hostname", with: reservation.hostname)
      expect(page).to have_field("Description", with: reservation.description)

      fill_in "HW address", with: "1a:1b:1c:1d:1e:1f"
      fill_in "IP address", with: "192.0.2.3"
      fill_in "Hostname", with: "testier.example.com"
      fill_in "Description", with: "Changed test reservation"

      # expect_config_to_be_published
      # expect_service_to_be_rebooted

      click_on "Update"

      expect(page).to have_content("Successfully updated reservation")
      expect(page).to have_content("1a:1b:1c:1d:1e:1f")
      expect(page).to have_content("192.0.2.3")
      expect(page).to have_content("testier.example.com")
      expect(page).to have_content("Changed test reservation")

      # click_on "Audit log"

      # expect(page).to have_content(editor.email)
      # expect(page).to have_content("update")
      # expect(page).to have_content("Option")
    end

    it "displays error if form cannot be submitted" do
      visit "/reservations/#{reservation.id}/edit"

      fill_in "HW address", with: ""
      fill_in "IP address", with: ""
      fill_in "Hostname", with: ""
      fill_in "Description", with: ""

      click_on "Update"

      expect(page).to have_content "There is a problem"
    end
  end
end