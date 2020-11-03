require "rails_helper"

describe "showing a reservation", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing a reservation" do
      visit "/reservations/nonexistant-reservation-id"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when the reservation exists" do
      let(:reservation) { create :reservation }
      let(:subnet) { reservation.subnet }

      it "allows viewing reservations and its options" do
        visit "/subnets/#{subnet.to_param}"

        click_on "View"

        expect(page).to have_content reservation.hw_address
        expect(page).to have_content reservation.ip_address
        expect(page).to have_content reservation.hostname
      end
    end
  end
end
