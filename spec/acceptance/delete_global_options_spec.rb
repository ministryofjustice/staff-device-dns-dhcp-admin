require "rails_helper"

describe "delete global options", type: :feature do
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "delete global options" do
    global_option = Audited.audit_class.as_user(editor) { create :global_option }
    visit "/global-options"

    click_on "Delete global options"

    expect(page).to have_content("Are you sure you want to delete the global options?")
    expect(page).to have_content(global_option.domain_name)
    expect(page).to have_content(global_option.domain_name_servers.join(", "))

    expect_config_to_be_verified
    expect_config_to_be_published

    click_on "Delete global options"

    expect(page).to have_content("Successfully deleted global options")
    expect(page).to have_content("This could take up to 10 minutes to apply.")
    expect(page).not_to have_content(global_option.domain_name)

    expect_audit_log_entry_for(editor.email, "destroy", "Global option")
  end
end
