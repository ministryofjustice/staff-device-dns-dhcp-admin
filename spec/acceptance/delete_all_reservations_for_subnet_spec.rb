require "rails_helper"

describe "delete all reservations in a subnet", type: :feature do
  let(:subnet) { create :subnet }
  let(:subnet2) { create :subnet}
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "deletes all reservations in the given subnet, without affecting any others" do

    first_reservation_in_subnet  = create :reservation, subnet: subnet
    second_reservation_in_subnet = create :reservation,
      subnet: subnet,
      hw_address: "ab:bb:cc:dd:ee:ff",
      ip_address: subnet.end_address,
      hostname: "test2.example.com"
    
    reservation_in_another_subnet = create :reservation,
    subnet: subnet2,
    hw_address: "a1:b5:c8:d4:e1:ff",
    ip_address: subnet2.start_address,
    hostname: "test99.example.com"

    visit "/subnets/#{subnet.to_param}"

    click_on "Delete all reservations"

    expect(page).to have_content("Are you sure you want to delete all reservations for the following subnet?")
    expect(page).to have_content(subnet.cidr_block)
    expect(page).to have_content(subnet.shared_network.site.name)

    expect_config_to_be_verified
    expect_config_to_be_published

    click_on "Delete all reservations"

    expect(page).to have_content("Successfully deleted all reservations for subnet #{subnet.cidr_block}")
    expect(page).to have_content("This could take up to 10 minutes to apply.")
    expect(page).not_to have_content(first_reservation_in_subnet.hw_address)
    expect(page).not_to have_content(second_reservation_in_subnet.hw_address)

    expect_audit_log_entry_for(editor.email, "delete all reservations", "Subnet (#{subnet.cidr_block})")

    visit "/subnets/#{subnet2.to_param}"

    expect(page).to have_content(reservation_in_another_subnet.hw_address)
  
  end

  it "there are no reservations and as such deletion is not an option to the user" do
    visit "/subnets/#{subnet.to_param}"

    expect(page).not_to have_content("Delete all reservations")
  end
end
