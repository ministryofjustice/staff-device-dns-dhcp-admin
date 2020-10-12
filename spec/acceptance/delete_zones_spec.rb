require "rails_helper"

describe "delete zones", type: :feature do
  before do
    login_as User.create!(editor: true)
  end

  it "delete a zone" do
    zone = create(:zone)

    visit "/dns"

    click_on "Delete"

    expect(page).to have_content("Are you sure you want to delete this zone?")

    click_on "Delete zone"

    expect(current_path).to eq("/dns")
    expect(page).to have_content("Successfully deleted zone")
    expect(page).not_to have_content(zone.name)
  end
end
