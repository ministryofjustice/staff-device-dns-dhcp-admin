require "rails_helper"

describe "update subnets", type: :feature do
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "update an existing subnet" do
    subnet = Audited.audit_class.as_user(User.first) { create(:subnet) }
    visit "/sites/#{subnet.site.to_param}"

    click_on "Edit"

    expect(page).to have_field("CIDR block", with: subnet.cidr_block)
    expect(page).to have_field("Start address", with: subnet.start_address)
    expect(page).to have_field("End address", with: subnet.end_address)

    fill_in "CIDR block", with: "10.1.1.0/24"
    fill_in "Start address", with: "10.1.1.1"
    fill_in "End address", with: "10.1.1.255"

    expect_config_to_be_verified
    expect_config_to_be_published
    expect_service_to_be_rebooted

    click_button "Update"

    expect(page).to have_content("Successfully updated subnet")

    expect(page).to have_content("10.1.1.0/24")
    expect(page).to have_content("10.1.1.1")
    expect(page).to have_content("10.1.1.255")

    expect_audit_log_entry_for(editor.email, "update", "Subnet")
  end
end
