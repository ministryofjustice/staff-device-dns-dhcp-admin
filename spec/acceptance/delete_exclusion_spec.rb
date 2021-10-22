require "rails_helper"

describe "delete exclusion", type: :feature do
  let(:exclusion) do
    Audited.audit_class.as_user(editor) do
      create :exclusion
    end
  end

  let(:subnet) { exclusion.subnet }
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "deletes an exclusion" do
    visit "/subnets/#{subnet.to_param}"

    click_on("Delete", match: :first)

    expect(page).to have_content("Are you sure you want to delete this exclusion?")
    expect(page).to have_content(exclusion.start_address)
    expect(page).to have_content(exclusion.end_address)

    expect_config_to_be_verified
    expect_config_to_be_published

    click_on "Delete exclusion"

    expect(page).to have_content("Successfully deleted exclusion")
    expect(page).to have_content("This could take up to 10 minutes to apply.")

    expect_audit_log_entry_for(editor.email, "destroy", "Exclusion")
  end
end
