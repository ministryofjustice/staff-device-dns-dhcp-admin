require "rails_helper"

describe "update subnets", type: :feature do
  let!(:subnet) { create(:subnet) }

  before do
    login_as User.create
  end

  it "update an existing subnet" do
    visit "/subnets"

    click_on "Edit"

    expect(page).to have_field("CIDR Block", with: subnet.cidr_block)
    expect(page).to have_field("Start Address", with: subnet.start_address)
    expect(page).to have_field("End Address", with: subnet.end_address)

    fill_in "CIDR Block", with: "10.1.1.0/24"
    fill_in "Start Address", with: "10.1.1.1"
    fill_in "End Address", with: "10.1.1.255"

    click_button "Update"

    expect(current_path).to eq("/subnets")

    expect(page).to have_content("10.1.1.0/24")
    expect(page).to have_content("10.1.1.1")
    expect(page).to have_content("10.1.1.255")
  end
end
