require "rails_helper"

describe "dhcp config parser page", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing the content of the page" do
      visit "/import"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is authenticated and the user is a reader" do
    before do
      login_as create(:user, :viewer)
    end

    it "shows a warning text" do
      visit "/import"

      expect(page).to have_content("You are not authorized to access this page.")
    end
  end

  context "when the user is authenticated and the user is a editor" do
    before do
      login_as create(:user, :editor)
    end

    it "does not show a warning text" do
      visit "/import"

      expect(page).not_to have_content("You are not authorized to access this page.")
    end

    it "the user can import a DHCP config file" do
      # Given a subnet (192.168.0.1) exists
      subnet = create :subnet,
        cidr_block: "192.168.0.0/24",
        start_address: "192.168.0.1",
        end_address: "192.168.0.255"

      # Given I am on the import page
      visit "/import"

      # When I select a config file
      attach_file "Import file", "./spec/fixtures/dxc_exports/export.txt"

      # And I provide a kea config file
      attach_file "Kea Config file", "./spec/fixtures/kea_configs/kea.json"

      # And I provide a subnet list
      fill_in "Subnet list", with: "192.168.0.1, 192.168.1.1"

      # And I provide a fits_id
      fill_in "FITS id", with: "MYFITS101"

      expect_config_to_be_verified
      expect_config_to_be_published

      # When I submit it
      click_on "Submit"

      # Then I see a confirmation
      expect(page).to have_content("Successfully ran the import.")

      # When I visit subnet page
      visit "/subnets/#{subnet.to_param}"

      # Then I can see a reservation
      expect(page).to have_content("a1:b2:c3:d4:e5:f7")

      # Also,
      # Act, Arrange, Assert
      # Given, When, Then
    end

    it "tells the user about any errors importing dhcp configs" do
      # given there is a subnet
      subnet = create :subnet,
        cidr_block: "192.168.0.0/24",
        start_address: "192.168.0.1",
        end_address: "192.168.0.255"

      # When i visit the import page
      visit "/import"

      # and i fill in the subnet cidr range
      fill_in "Subnet list", with: "192.168.0.1, 192.168.1.1"

      # and i fill in the fits id
      fill_in "FITS id", with: "MYFITS101"

      # and i upload the import file
      attach_file "Import file", "./spec/fixtures/dxc_exports/export.txt"

      # And I provide a kea config file
      attach_file "Kea Config file", "./spec/fixtures/kea_configs/kea.json"

      # and the kea server says the config is invalid
      allow_config_verification_to_fail_with_message("this isnt what kea looks like :(")

      # when i submit
      click_on "Submit"

      # then i should see the kea server validation errors
      expect(page).to have_content("this isnt what kea looks like :(")
    end

    it "cancels all updates if there are any errors or duplicates" do
      # given there is a subnet
      subnet = create :subnet,
        cidr_block: "192.168.0.0/24",
        start_address: "192.168.0.1",
        end_address: "192.168.0.255"

      # with an existing reservation
      reservation = create :reservation,
        subnet: subnet,
        hw_address: "f7:e5:d4:c3:b2:a1",
        ip_address: "192.168.0.30",
        hostname: "windowsmachine4.test.space.local"

      # When i visit the import page
      visit "/import"

      # and i fill in the subnet cidr range
      fill_in "Subnet list", with: "192.168.0.0"

      # and i fill in the fits id
      fill_in "FITS id", with: "MYFITS101"

      # and i upload the import file
      attach_file "Import file", "./spec/fixtures/dxc_exports/export.txt"

      # And I provide a kea config file
      attach_file "Kea Config file", "./spec/fixtures/kea_configs/kea.json"

      # when i submit
      click_on "Submit"

      # then errors are presented on the import page (not blow up)
      expect(page).to have_content "There is a problem"
      expect(page).to have_content "IP address 192.168.0.30 has already been reserved in the subnet 192.168.0.0/24"

      # And none of the updates should have been run
      visit "/subnets/#{subnet.to_param}"

      expect(page).to have_content "192.168.0.30"
      expect(page).to have_content "f7:e5:d4:c3:b2:a1"
      expect(page).not_to have_content "a1:b2:c3:d4:e5:f7"
    end
  end
end
