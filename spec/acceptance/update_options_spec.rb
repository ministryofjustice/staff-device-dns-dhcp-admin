require "rails_helper"

describe "update options", type: :feature do
  let(:option) { create(:option) }
  let(:subnet) { option.subnet }

  context "when a user is not logged in" do
    it "it does not allow editing options" do
      visit "/subnets/#{subnet.to_param}/options/edit"

      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end

  context "when a user is logged in as an viewer" do
    before do
      login_as User.create!(editor: false)
    end

    it "does not allow editing options" do
      visit "/subnets/#{subnet.to_param}"

      expect(page).not_to have_content("Edit options")

      visit "/subnets/#{subnet.to_param}/options/edit"

      expect(page).to have_content("You are not authorized to access this page.")
    end
  end

  context "when a user is logged in as an editor" do
    let(:editor) { User.create!(editor: true) }

    before do
      login_as editor
    end

    it "edits an existing option" do
      visit "/subnets/#{subnet.to_param}"

      expect(page).not_to have_content("Create options")
      click_on "Edit options"

      expect(page).to have_field("Routers", with: option.routers.join(","))
      expect(page).to have_field("Domain name servers", with: option.domain_name_servers.join(","))
      expect(page).to have_field("Domain name", with: option.domain_name)

      fill_in "Routers", with: "10.0.1.1,10.0.1.3"
      fill_in "Domain name servers", with: "10.0.2.2,10.0.2.3"
      fill_in "Domain name", with: "testier.example.com"

      expect_config_to_be_published
      expect_service_to_be_rebooted

      click_on "Update"

      expect(page).to have_content("Successfully updated options")
      expect(page).to have_content("10.0.1.1,10.0.1.3")
      expect(page).to have_content("10.0.2.2,10.0.2.3")
      expect(page).to have_content("testier.example.com")

      click_on "Audit log"

      expect(page).to have_content("#{editor.id}")
      expect(page).to have_content("update")
      expect(page).to have_content("Option")
    end

    it "displays error if form cannot be submitted" do
      visit "/subnets/#{subnet.to_param}/options/edit"

      fill_in "Routers", with: ""
      fill_in "Domain name servers", with: ""
      fill_in "Domain name", with: ""

      click_on "Update"

      expect(page).to have_content "There is a problem"
    end
  end
end
