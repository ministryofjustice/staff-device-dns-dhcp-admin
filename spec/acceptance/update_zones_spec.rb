require "rails_helper"

describe "update zones", type: :feature do
  let!(:zone) { create(:zone) }
  let(:editor) { User.create!(editor: true) }

  before do
    login_as editor
  end

  it "update an existing zone" do
    visit "/dns"

    click_on "Edit"

    expect(page).to have_field("Domain name", with: zone.name)
    expect(page).to have_field("Forwarders", with: zone.forwarders.join(","))
    expect(page).to have_field("Purpose", with: zone.purpose)

    fill_in "Domain name", with: "test.example.com"
    fill_in "Forwarders", with: "127.0.0.2,127.0.0.1"
    fill_in "Purpose", with: "UI Testing for Updating"

    click_button "Update"

    expect(current_path).to eq("/dns")

    expect(page).to have_content("test.example.com")
    expect(page).to have_content("127.0.0.2,127.0.0.1")
    expect(page).to have_content("UI Testing for Updating")

    click_on "Audit log"

    expect(page).to have_content(editor.id.to_s)
    expect(page).to have_content("update")
    expect(page).to have_content("Zone")
  end

  it "displays error if form cannot be submitted" do
    visit "/zones/#{zone.id}/edit"

    fill_in "Forwarders", with: "fail;"

    click_button "Update"

    expect(page).to have_content "There is a problem"
  end
end
