require "rails_helper"

describe "create subnet options", type: :feature do
  let(:subnet) { create(:subnet) }

  context "when a user is not logged in" do
    it "it does not allow editing options" do
      visit "/subnets/#{subnet.to_param}/options/new"

      expect(page).to have_content("You need to sign in or sign up before continuing.")
    end
  end

  context "when a user is logged in as an viewer" do
    before do
      login_as User.create!(editor: false)
    end

    it "does not allow editing options" do
      visit "/subnets/#{subnet.to_param}"

      expect(page).not_to have_content("Edit options")

      visit "/subnets/#{subnet.to_param}/options/new"

      expect(page).to have_content("You are not authorized to access this page.")
    end
  end
end
