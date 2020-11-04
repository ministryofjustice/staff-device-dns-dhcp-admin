require "rails_helper"

describe "delete reservation options", type: :feature do
  let(:reservation_option) do
    Audited.audit_class.as_user(editor) do
      create :reservation_option
    end
  end

  let(:reservation) { reservation_option.reservation }
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "delete a reservation option" do
    visit "/reservations/#{reservation.to_param}"

    click_on "Delete"

    expect(page).to have_content("Are you sure you want to delete these options?")

    # expect_config_to_be_published
    # expect_service_to_be_rebooted

    click_on "Delete reservation options"

    expect(page).to have_content("Successfully deleted reservation options")
    expect(page).not_to have_content(reservation_option.domain_name)
    expect(page).not_to have_content(reservation_option.routers)

    # expect_audit_log_entry_for(editor.email, "destroy", "Option")
  end
end