require "rails_helper"

describe "delete all reservations in a subnet", type: :feature do
  let(:subnet) { create :subnet }
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "delete all reservations" do
    reservation1 = create :reservation, subnet: subnet 
    reservation2 = create :reservation, subnet: subnet

    visit "/subnets/#{subnet.to_param}"

    click_on "Delete all reservations"

    expect(page).to have_content("Are you sure you want to delete all reservations for the following subnet?")
    expect(page).to have_content(subnet.cidr_block)

    expect_config_to_be_verified
    expect_config_to_be_published

    click_on "Delete all reservations"

    expect(page).to have_content("Successfully deleted all reservations for subnet #{subnet.cidr_block}")
    expect(page).to have_content("This could take up to 10 minutes to apply.")
    expect(page).not_to have_content(reservation1.hw_address)
    expect(page).not_to have_content(reservation2.hw_address)

    expect_audit_log_entry_for(editor.email, "destroy", "Reservation")
  end
end
