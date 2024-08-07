require "rails_helper"

describe "create zones", type: :feature do
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "creates a new zone" do
    visit "/dns"

    click_on "Create a new zone"

    fill_in "Domain name", with: "test.example.com"
    fill_in "Forwarders", with: "10.1.1.25,10.1.1.28"
    fill_in "Purpose", with: "Frontend Driven Test"

    click_button "Create"

    expect(page).to have_content("Successfully created zone")

    zone = Zone.last
    expect(zone.name).to eq "test.example.com"
    expect(zone.forwarders).to eq ["10.1.1.25", "10.1.1.28"]
    expect(zone.purpose).to eq "Frontend Driven Test"

    expect_audit_log_entry_for(editor.email, "create", "Zone")
  end

  it "displays error if form cannot be submitted" do
    visit "/zones/new"

    click_button "Create"

    expect(page).to have_content "There is a problem"
  end
end
