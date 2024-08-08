require "rails_helper"

describe "creating a subnet extension", type: :feature do
  let(:editor) { create(:user, :editor) }
  let(:subnet) { Audited.audit_class.as_user(editor) { create(:subnet) } }
  before do
    login_as editor
  end

  it "creates a new subnet in a shared network" do
    visit "/subnets/#{subnet.to_param}"

    expect(page).to have_content("Subnets in the same shared network")

    click_on "Add a subnet to this shared network"

    expect(page).to have_content("Extending a shared network")
    expect(page).to have_content("Extend with an existing subnet")
    expect(page).to have_content("Extend with a new subnet")

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

  it "displays validation errors if form cannot be submitted" do
    visit "/subnets/#{subnet.to_param}/extensions/new"

    click_on "Create"

    expect(page).to have_content "There is a problem"
    expect(page).to have_content "CIDR block can't be blank"
  end
  
  it "displays dhcp config verification errors" do
    visit "/subnets/#{subnet.to_param}/extensions/new"

    when_i_fill_in_the_form_with_valid_data

    allow_config_verification_to_fail_with_message("this isnt what kea looks like :(")

    click_on "Create"

    expect(page).to have_content "There is a problem"
    expect(page).to have_content "this isnt what kea looks like :("
  end  

  def when_i_fill_in_the_form_with_valid_data
    fill_in "CIDR block", with: "10.0.1.0/24"
    fill_in "Start address", with: "10.0.1.1"
    fill_in "End address", with: "10.0.1.255"
    fill_in "Routers", with: "10.0.1.0,10.0.1.2"
  end
end
