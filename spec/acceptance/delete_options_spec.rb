require "rails_helper"

describe "delete options", type: :feature do
  let(:option) { create :option }
  let(:subnet) { option.subnet }
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "delete an option" do
    visit "/subnets/#{subnet.to_param}"

    click_on "Delete options"

    expect(page).to have_content("Are you sure you want to delete these options?")

    expect_config_to_be_published
    expect_service_to_be_rebooted

    click_on "Delete option"

    expect(page).to have_content("Successfully deleted option")
    expect(page).not_to have_content(option.domain_name)

    click_on "Audit log"

    expect(page).to have_content(editor.id.to_s)
    expect(page).to have_content("destroy")
    expect(page).to have_content("Option")
  end
end
