require "rails_helper"

describe "create subnets", type: :feature do
  before do
    login_as User.create
  end

  it "creates a new subnet" do
    visit "/subnets"

    click_on "Create a new subnet"

    expect(current_path).to eql("/subnets/new")

    fill_in "CIDR Block", with: "10.0.1.0/24"
    fill_in "Start Address", with: "10.0.1.1"
    fill_in "End Address", with: "10.0.1.255"

    click_button "Create"

    expect(current_path).to eq("/subnets")

    subnet = Subnet.last
    expect(subnet.cidr_block).to eq "10.0.1.0/24"
    expect(subnet.start_address).to eq "10.0.1.1"
    expect(subnet.end_address).to eq "10.0.1.255"
  end

  it "displays error if form cannot be submitted" do
    visit "/subnets/new"

    fill_in "CIDR Block", with: "a"
    fill_in "Start Address", with: "b"
    fill_in "End Address", with: "c"

    click_button "Create"

    expect(page).to have_content "There is a problem"
  end
end
