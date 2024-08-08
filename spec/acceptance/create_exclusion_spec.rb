require "rails_helper"

describe "create exclusion", type: :feature do
  let(:subnet) do
    Audited.audit_class.as_user(User.first) do
      create(:subnet)
    end
  end

  context "when a user is logged in as an editor" do
    let(:editor) { create :user, :editor }

    before do
      login_as editor
    end

    it "creates a new subnet exclusion" do
      visit "/subnets/#{subnet.to_param}"

      expect(page).not_to have_content("Edit exclusion")
      click_on "Create exclusion"

      when_i_fill_in_the_form_with_valid_data

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Create"

      expect(page).to have_content("Successfully created exclusion")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("Start Address #{subnet.start_address.gsub(/([1-9]{1,3})$/, "50")}")
      expect(page).to have_content("End Address #{subnet.start_address.gsub(/([1-9]{1,3})$/, "100")}")

      expect_audit_log_entry_for(editor.email, "create", "Exclusion")
    end

    it "displays validation errors if the record fails to save" do
      visit "/subnets/#{subnet.to_param}/exclusions/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "Start address can't be blank"
    end

    it "displays dhcp config verification errors" do
      visit "/subnets/#{subnet.to_param}/exclusions/new"

      when_i_fill_in_the_form_with_valid_data

      allow_config_verification_to_fail_with_message("this isnt what kea looks like :(")

      click_on "Create"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "this isnt what kea looks like :("
    end
  end

  def when_i_fill_in_the_form_with_valid_data
    fill_in "Start address", with: subnet.start_address.gsub(/([1-9]{1,3})$/, "50")
    fill_in "End address", with: subnet.end_address.gsub(/([1-9]{1,3})$/, "100")
  end
end