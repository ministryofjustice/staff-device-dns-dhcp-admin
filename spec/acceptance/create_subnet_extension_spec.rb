require "rails_helper"

describe "creating a subnet extension", type: :feature do
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "creates a new subnet in a shared network" do
    subnet = Audited.audit_class.as_user(editor) { create :subnet }
    visit "/subnets/#{subnet.to_param}"

    click_on "Extend this network with another subnet"

    fill_in "CIDR block", with: "10.0.1.0/24"
    fill_in "Start address", with: "10.0.1.1"
    fill_in "End address", with: "10.0.1.255"
    fill_in "Routers", with: "10.0.1.0,10.0.1.2"

    expect_config_to_be_verified
    expect_config_to_be_published

    click_button "Create"

    expect(page).to have_content("10.0.1.0/24")
    expect(page).to have_content("10.0.1.1")
    expect(page).to have_content("10.0.1.255")
    expect(page).to have_content("10.0.1.0, 10.0.1.2")

    expect_audit_log_entry_for(editor.email, "create", "Subnet")
  end

  it "displays error if form cannot be submitted" do
    subnet = create :subnet
    visit "/subnets/#{subnet.to_param}"

    click_on "Extend this network with another subnet"

    fill_in "CIDR block", with: "a"
    fill_in "Start address", with: "b"
    fill_in "End address", with: "c"
    fill_in "Routers", with: "d"

    click_button "Create"

    expect(page).to have_content "There is a problem"
  end
end
