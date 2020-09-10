require "rails_helper"

describe "delete subnets", type: :feature do
  before do
    login_as User.create!(editor: true)
  end

  it "delete a subnet" do
    subnet = create(:subnet)

    visit "/subnets"

    click_on "Delete"

    expect(page).to have_content("Are you sure you want to delete this subnet?")

    click_on "Delete subnet"

    expect(current_path).to eq("/subnets")
    expect(page).to have_content("Successfully deleted subnet")
    expect(page).not_to have_content(subnet.cidr_block)
  end
end
