require "rails_helper"

describe "create subnets", type: :feature do
  let(:editor) { create(:user, :editor) }
  let(:site) { Audited.audit_class.as_user(editor) { create :site } }

  before do
    login_as editor
  end

  it "creates a new subnet" do
    visit "/sites/#{site.to_param}"

    click_on "Create a new subnet"

    expect(current_path).to eql("/sites/#{site.to_param}/subnets/new")
    expect(page).to_not have_content("Global Options")

    when_i_fill_in_the_form_with_valid_data

    expect_config_to_be_verified
    expect_config_to_be_published

    click_button "Create"

    expect(current_path).to eq("/subnets/#{site.subnets.first.to_param}")

    expect(page).to have_content("10.0.1.0/24")
    expect(page).to have_content("10.0.1.1")
    expect(page).to have_content("10.0.1.255")
    expect(page).to have_content("10.0.1.0, 10.0.1.2")

    expect_audit_log_entry_for(editor.email, "create", "Subnet")
  end

  it "shows the user any defined global options" do
    site = create :site
    global_option = create :global_option

    visit "/sites/#{site.to_param}"

    click_on "Create a new subnet"

    expect(page).to have_content("Global Options")
    expect(page).to have_content(global_option.domain_name_servers.join(","))
    expect(page).to have_content(global_option.domain_name)
  end

  it "displays validation errors if form cannot be submitted" do
    visit "/sites/#{site.to_param}/subnets/new"

    click_on "Create"

    expect(page).to have_content "There is a problem"
    expect(page).to have_content "CIDR block can't be blank"
  end

  it "displays dhcp config verification errors" do
    visit "/sites/#{site.to_param}/subnets/new"

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
