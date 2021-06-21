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

      fill_in "Start address", with: subnet.start_address.gsub(/([1-9]{1,3})$/, "50")
      fill_in "End address", with: subnet.end_address.gsub(/([1-9]{1,3})$/, "100")

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Create"

      expect(page).to have_content("Successfully created exclusion")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("Start Address #{subnet.start_address.gsub(/([1-9]{1,3})$/, "50")}")
      expect(page).to have_content("End Address #{subnet.start_address.gsub(/([1-9]{1,3})$/, "100")}")

      expect_audit_log_entry_for(editor.email, "create", "Exclusion")
    end
  end
end
