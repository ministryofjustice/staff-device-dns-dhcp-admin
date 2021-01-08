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

      fill_in "Domain name servers", with: "10.0.2.1,10.0.2.2"
      fill_in "Domain name", with: "test.example.com"
      fill_in "Valid lifetime", with: "12345"

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Create"

      expect(page).to have_content("Successfully created option")
      expect(page).to have_content("10.0.2.1,10.0.2.2")
      expect(page).to have_content("test.example.com")
      expect(page).to have_content("12345")

      expect_audit_log_entry_for(editor.email, "create", "Option")
    end

    it "displays error if form cannot be submitted" do
      visit "/subnets/#{subnet.to_param}/options/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
    end
  end
end
