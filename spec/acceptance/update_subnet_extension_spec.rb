require "rails_helper"

describe "updating a subnet extension", type: :feature do
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "moves a subnet from one shared network to another" do
    subnet_a = create :subnet
    subnet_b = create :subnet, shared_network: create(:shared_network, site: subnet_a.shared_network.site)
    subnet_in_subnet_b_shared_network = create :subnet, shared_network: subnet_b.shared_network

    visit "/subnets/#{subnet_in_subnet_b_shared_network.to_param}"
    expect(page).to have_content(subnet_b.cidr_block)

    visit "/subnets/#{subnet_a.to_param}"
    expect(page).to have_no_content(subnet_b.cidr_block)

    click_on "Add a subnet to this shared network"

    select subnet_b.cidr_block, from: "Subnet"

    click_button "Add to shared network"

    expect(page).to have_content("Are you sure you want to add the above subnet to a shared network?")

    expect_config_to_be_verified
    expect_config_to_be_published

    click_button "Add to shared network"

    expect(page).to have_content(subnet_a.cidr_block)
    expect(page).to have_content(subnet_b.cidr_block)

    visit "/subnets/#{subnet_in_subnet_b_shared_network.to_param}"

    expect(page).to have_content(subnet_in_subnet_b_shared_network.cidr_block)
    expect(page).to have_no_content(subnet_b.cidr_block)
  end
end
