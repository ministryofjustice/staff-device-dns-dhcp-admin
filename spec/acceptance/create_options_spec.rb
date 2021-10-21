require "rails_helper"

describe "create options", type: :feature do
  let(:subnet) do
    Audited.audit_class.as_user(User.first) do
      create(:subnet)
    end
  end

  context "when a user is not logged in" do
    it "it does not allow editing options" do
      visit "/subnets/#{subnet.to_param}/options/new"

      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end

  context "when a user is logged in as an viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing options" do
      visit "/subnets/#{subnet.to_param}"

      expect(page).not_to have_content("Create options")

      visit "/subnets/#{subnet.to_param}/options/new"

      expect(page).to have_content("You are not authorized to access this page.")
    end
  end

  context "when a user is logged in as an editor" do
    let(:editor) { create :user, :editor }

    before do
      login_as editor
    end

    it "creates a new subnet option" do
      visit "/subnets/#{subnet.to_param}"

      expect(page).not_to have_content("Edit options")
      click_on "Create options"

      expect(page).to_not have_content("Global Options")
      expect(page).to_not have_content("Subnet specific options will override the global options.")

      when_i_fill_in_the_form_with_valid_data

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Create"

      expect(page).to have_content("Successfully created option")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("10.0.2.1,10.0.2.2")
      expect(page).to have_content("test.example.com")
      expect(page).to have_content("12345 seconds")

      expect_audit_log_entry_for(editor.email, "create", "Option")
    end

    it "shows the user any defined global options" do
      subnet = create :subnet
      global_option = create :global_option

      visit "/subnets/#{subnet.to_param}"

      click_on "Create options"

      expect(page).to have_content("Global Options")
      expect(page).to have_content("Subnet specific options will override the global options.")
      expect(page).to have_content(global_option.domain_name_servers.join(","))
      expect(page).to have_content(global_option.domain_name)
    end

    it "edit subnet option to have a valid lifetime of 1 day" do
      visit "/subnets/#{subnet.to_param}"

      expect(page).not_to have_content("Edit options")
      click_on "Create options"

      fill_in "Domain name servers", with: "10.0.2.1,10.0.2.2"
      fill_in "Domain name", with: "test.example.com"
      fill_in "Valid lifetime", with: "1"
      select "Days", from: "option[valid_lifetime_unit]"

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Create"

      expect(page).to have_content("1 day")

      expect_audit_log_entry_for(editor.email, "create", "Option")
    end

    it "displays validation errors if the record fails to save" do
      visit "/subnets/#{subnet.to_param}/options/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "At least one option must be filled out"
    end

    it "displays dhcp config verification errors" do
      visit "/subnets/#{subnet.to_param}/options/new"

      when_i_fill_in_the_form_with_valid_data

      allow_config_verification_to_fail_with_message("this isnt what kea looks like :(")

      click_on "Create"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "this isnt what kea looks like :("
    end

    def when_i_fill_in_the_form_with_valid_data
      fill_in "Domain name servers", with: "10.0.2.1,10.0.2.2"
      fill_in "Domain name", with: "test.example.com"
      fill_in "Valid lifetime", with: "12345"
      select "Seconds", from: "option[valid_lifetime_unit]"
    end
  end
end
