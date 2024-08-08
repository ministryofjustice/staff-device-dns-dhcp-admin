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

  context "when a user is logged in as a support user" do
    let(:second_line_support) { create(:user, :second_line_support) }

    before do
      login_as second_line_support
    end

    it "creates a new subnet reservation" do
      reservation_ip = reservation.subnet.start_address.chop + "25"

      visit "/subnets/#{reservation.subnet_id}"

      click_on "Create a new reservation"

      expect(page).to have_content(reservation.subnet.start_address + " to " + reservation.subnet.end_address)

      fill_in "HW address", with: "1a:bb:cc:dd:ee:fe"
      fill_in "IP address", with: reservation_ip
      fill_in "Hostname", with: "test_example3.com"
      fill_in "Description", with: "Test reservation 2"

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Create"

      expect(page).to have_content("Successfully created reservation")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("1a:bb:cc:dd:ee:fe")
      expect(page).to have_content(reservation_ip)
      expect(page).to have_content("test_example3.com")
      expect(page).to have_content("Test reservation 2")

      expect_audit_log_entry_for(second_line_support.email, "create", "Reservation")
    end
  end

  context "when a user is logged in as a viewer" do
    before do
      login_as create(:user, :viewer)
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

      expect(page).to have_content(reservation.subnet.start_address + " to " + reservation.subnet.end_address)

      fill_in "HW address", with: "01:bb:cc:dd:ee:fe"
      fill_in "IP address", with: reservation.subnet.end_address
      fill_in "Hostname", with: "test.example2.com"
      fill_in "Description", with: "Test reservation"

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Create"

      expect(page).to have_content("Successfully created reservation")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("01:bb:cc:dd:ee:fe")
      expect(page).to have_content(reservation.subnet.end_address)
      expect(page).to have_content("test.example2.com")
      expect(page).to have_content("Test reservation")

      expect_audit_log_entry_for(editor.email, "create", "Reservation")
    end

    it "creates a new subnet reservation without a hostname" do
      no_hostname_reservation_ip = reservation.subnet.start_address.chop + "26"

      visit "/subnets/#{reservation.subnet_id}"

      click_on "Create a new reservation"

      expect(page).to have_content(reservation.subnet.start_address + " to " + reservation.subnet.end_address)

      fill_in "HW address", with: "02:bb:cc:dd:ee:fe"
      fill_in "IP address", with: no_hostname_reservation_ip

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Create"

      expect(page).to have_content("Successfully created reservation")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("02:bb:cc:dd:ee:fe")
      expect(page).to have_content(no_hostname_reservation_ip)
      expect_audit_log_entry_for(editor.email, "create", "Reservation")
    end

    it "displays validations errors if form cannot be submitted" do
      visit "/subnets/#{reservation.subnet_id}/reservations/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "HW address can't be blank"
    end

    it "displays dhcp config verification errors" do
      visit "/subnets/#{reservation.subnet_id}/reservations/new"

      when_i_fill_in_the_form_with_valid_data

      allow_config_verification_to_fail_with_message("this isnt what kea looks like :(")

      click_on "Create"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "this isnt what kea looks like :("
    end
  end

  def when_i_fill_in_the_form_with_valid_data
    fill_in "HW address", with: "01:bb:cc:dd:ee:fe"
    fill_in "IP address", with: reservation.subnet.end_address
    fill_in "Hostname", with: "test.example2.com"
    fill_in "Description", with: "Test reservation"
  end
end
