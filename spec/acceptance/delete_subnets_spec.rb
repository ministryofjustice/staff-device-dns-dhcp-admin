require "rails_helper"

describe "delete subnets", type: :feature do
  let(:editor) { User.create!(editor: true) }

  before do
    login_as editor
  end

  it "delete a subnet" do
    subnet = create(:subnet)

    visit "/sites/#{subnet.site.to_param}"

    click_on "Delete"

    expect(page).to have_content("Are you sure you want to delete this subnet?")

    click_on "Delete subnet"

    expect(page).to have_content("Successfully deleted subnet")
    expect(page).not_to have_content(subnet.cidr_block)

    click_on "Audit log"

    expect(page).to have_content("#{editor.id}")
    expect(page).to have_content("destroy")
    expect(page).to have_content("Subnet")
  end
end
