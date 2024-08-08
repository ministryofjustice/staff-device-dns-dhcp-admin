require "rails_helper"

describe "update subnets", type: :feature do
  let(:editor) { create(:user, :editor) }
  let(:subnet) { Audited.audit_class.as_user(User.first) { create(:subnet) } }

  before do
    login_as editor
  end

  it "update an existing subnet" do
    visit "/subnets/#{subnet.id}"

    expect(current_path).to eq("/subnets/#{subnet.id}")

    first(:link, "Change").click

    expect(page).to_not have_content("Global Options")
    expect(page).to have_field("CIDR block", with: subnet.cidr_block)
    expect(page).to have_field("Start address", with: subnet.start_address)
    expect(page).to have_field("End address", with: subnet.end_address)
    expect(page).to have_field("Routers", with: subnet.routers.join(","))

    fill_in "CIDR block", with: "10.1.1.0/24"
    fill_in "Start address", with: "10.1.1.1"
    fill_in "End address", with: "10.1.1.255"
    fill_in "Routers", with: "10.0.1.1, 10.0.1.3"

    expect_config_to_be_verified
    expect_config_to_be_published

    click_button "Update"

    expect(page).to have_content("Successfully updated subnet")
    expect(page).to have_content("This could take up to 10 minutes to apply.")
    expect(page).to have_content("10.1.1.0/24")
    expect(page).to have_content("10.1.1.1")
    expect(page).to have_content("10.1.1.255")
    expect(page).to have_content("10.0.1.1, 10.0.1.3")

    expect_audit_log_entry_for(editor.email, "update", "Subnet")
  end

  it "shows the user any defined global options" do
    subnet = create(:subnet)
    global_option = create :global_option

    visit "/subnets/#{subnet.id}"

    first(:link, "Change").click

    expect(page).to have_content("Global Options")
    expect(page).to have_content(global_option.domain_name_servers.join(","))
    expect(page).to have_content(global_option.domain_name)
  end

  it "displays validation errors if form cannot be submitted" do
    visit "/subnets/#{subnet.id}/edit"

    fill_in "CIDR block", with: ""

    click_on "Update"

    expect(page).to have_content "There is a problem"
    expect(page).to have_content "CIDR block can't be blank"
  end

  it "displays dhcp config verification errors" do
    visit "/subnets/#{subnet.id}/edit"

    allow_config_verification_to_fail_with_message("this isnt what kea looks like :(")

    click_on "Update"

    expect(page).to have_content "There is a problem"
    expect(page).to have_content "this isnt what kea looks like :("
  end
end
