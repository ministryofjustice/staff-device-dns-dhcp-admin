require "rails_helper"

describe "delete gobal options", type: :feature do
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "delete global options" do
    global_option = Audited.audit_class.as_user(editor) { create :global_option }
    visit "/global-options"

    click_on "Delete global options"

    expect(page).to have_content("Are you sure you want to delete the global options?")

    click_on "Delete global options"

    expect(page).to have_content("Successfully deleted global options")
    expect(page).not_to have_content(global_option.domain_name)

    expect_audit_log_entry_for(editor.email, "destroy", "Global option")
  end
end
