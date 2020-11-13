require "rails_helper"

describe "delete client class", type: :feature do
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "delete client class" do
    client_class = Audited.audit_class.as_user(editor) { create :client_class }
    visit "/client-classes"

    click_on "Delete client class"

    expect(page).to have_content("Are you sure you want to delete the client class?")

    click_on "Delete client class"

    expect(page).to have_content("Successfully deleted client class")
    expect(page).not_to have_content(client_class.domain_name)

    expect_audit_log_entry_for(editor.email, "destroy", "Client class")
  end
end
