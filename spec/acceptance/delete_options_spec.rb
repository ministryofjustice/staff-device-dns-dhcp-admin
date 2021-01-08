require "rails_helper"

describe "delete options", type: :feature do
  let(:option) do
    Audited.audit_class.as_user(editor) do
      create :option
    end
  end

  let(:subnet) { option.subnet }
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "delete an option" do
    visit "/subnets/#{subnet.to_param}"

    click_on "Delete options"

    expect(page).to have_content("Are you sure you want to delete these options?")

    expect_config_to_be_verified
    expect_config_to_be_published

    click_on "Delete option"

    expect(page).to have_content("Successfully deleted option")
    expect(page).not_to have_content(option.domain_name)

    expect_audit_log_entry_for(editor.email, "destroy", "Option")
  end
end
