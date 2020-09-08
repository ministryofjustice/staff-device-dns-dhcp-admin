require "rails_helper"

describe "update zones", type: :feature do
  let!(:zone) { create(:zone) }

  before do
    login_as User.create
  end

  it "update an existing zone" do
    visit "/zones"

    click_on "Edit"

    expect(page).to have_field("Name", with: zone.name)
    expect(page).to have_field("Forwarders", with: zone.forwarders)
    expect(page).to have_field("Purpose", with: zone.purpose)

    fill_in "Name", with: "test.example.com"
    fill_in "Forwarders", with: "127.0.0.2;127.0.0.1;"
    fill_in "Purpose", with: "UI Testing for Updating"

    click_button "Update"

    expect(current_path).to eq("/zones")

    expect(page).to have_content("test.example.com")
    expect(page).to have_content("127.0.0.2;127.0.0.1;")
    expect(page).to have_content("UI Testing for Updating")
  end

  it "displays error if form cannot be submitted" do
    visit "/zones/#{zone.id}/edit"

    fill_in "Forwarders", with: "fail;"

    click_button "Update"

    expect(page).to have_content "There is a problem"
  end
end
