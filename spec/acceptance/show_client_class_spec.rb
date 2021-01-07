require "rails_helper"

describe "showing a client class", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing client_class" do
      visit "/client-classes/nonexistant-clien-class-id"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when the client class exists" do
      let!(:client_class) { create :client_class }

      it "allows viewing client_class and its subnets" do
        visit "/client-classes"

        click_on "View", match: :first

        expect(page).to have_content client_class.name
        expect(page).to have_content client_class.client_id
        expect(page).to have_content client_class.domain_name_servers.join(",")
        expect(page).to have_content client_class.domain_name
      end
    end
  end
end
