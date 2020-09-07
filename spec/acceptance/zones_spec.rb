require "rails_helper"

describe "GET /zones", type: :feature do
  before do
    login_as User.new
  end

  it "lists zones" do
    zone = create :zone
    zone2 = create :zone, name: "test.example.com"

    visit "/zones"
    expect(page).to have_content zone.name
    expect(page).to have_content zone.forwarders
    expect(page).to have_content zone.purpose

    expect(page).to have_content zone2.name
  end
end
