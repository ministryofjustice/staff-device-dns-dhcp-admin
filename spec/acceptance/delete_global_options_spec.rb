require "rails_helper"

describe "delete gobal options", type: :feature do
  before do
    login_as User.create!(editor: true)
  end

  it "delete global options" do
    global_option = create :global_option
    visit "/global_options"

    click_on "Delete global options"

    expect(page).to have_content("Are you sure you want to delete the global options?")

    click_on "Delete global options"

    expect(page).to have_content("Successfully deleted global options")
    expect(page).not_to have_content(global_option.domain_name)
  end
end
