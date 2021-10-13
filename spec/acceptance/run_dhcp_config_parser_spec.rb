require "rails_helper"

describe "dhcp config parser page", type: :feature do
    context "when the user is unauthenticated" do
      it "does not allow viewing the content of the page" do
        visit "/import"
  
        expect(page).to have_content "You need to sign in or sign up before continuing."
      end
    end

    context "when the user is authenticated" do
        before do
          login_as create(:user, :reader)
        end
          
        it "allows viewing the content of the page" do
          visit "/import"

          expect(page).to have_content "Import Data"
        end
    end
end