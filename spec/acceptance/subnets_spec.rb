require "rails_helper"

describe "GET /subnets", type: :feature do
  before do
    login_as User.new
  end

  it "lists subnets" do
    subnet = create :subnet
    subnet2 = create :subnet, cidr_block: "10.0.10.0/24"

    visit "/subnets"
    expect(page).to have_content subnet.cidr_block
    expect(page).to have_content subnet.start_address
    expect(page).to have_content subnet.end_address

    expect(page).to have_content subnet2.cidr_block
  end
end
