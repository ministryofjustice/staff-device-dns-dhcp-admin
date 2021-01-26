require "rails_helper"

describe "update subnets", type: :feature do
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "update an existing subnet" do
    subnet = Audited.audit_class.as_user(User.first) { create(:subnet) }
    visit "/subnets/#{subnet.id}"

    expect(current_path).to eq("/subnets/#{subnet.id}")

    first(:link, "Change").click

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
end
