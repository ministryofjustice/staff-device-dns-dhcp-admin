require "rails_helper"

describe "update zones", type: :feature do
  let!(:zone) do
    Audited.audit_class.as_user(editor) do
      create(:zone)
    end
  end

  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "update an existing zone" do
    visit "/dns"

    click_on "Manage"

    expect(page).to have_field("Domain name", with: zone.name)
    expect(page).to have_field("Forwarders", with: zone.forwarders.join(","))
    expect(page).to have_field("Purpose", with: zone.purpose)

    fill_in "Domain name", with: "test.example.com"
    fill_in "Forwarders", with: "127.0.0.2,127.0.0.1"
    fill_in "Purpose", with: "UI Testing for Updating"

    click_button "Update"

    expect(page).to have_content("Successfully updated zone")

    expect(page).to have_content("test.example.com")
    expect(page).to have_content("127.0.0.2,127.0.0.1")
    expect(page).to have_content("UI Testing for Updating")

    expect_audit_log_entry_for(editor.email, "update", "Zone")
  end

  it "displays error if form cannot be submitted" do
    visit "/zones/#{zone.id}/edit"

    fill_in "Forwarders", with: "fail;"

    click_button "Update"

    expect(page).to have_content "There is a problem"
  end
end
