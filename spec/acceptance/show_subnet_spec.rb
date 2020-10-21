require "rails_helper"

describe "showing a subnet", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing subnets" do
      visit "/subnets/nonexistant-subnet-id"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when the subnet exists" do
      let(:subnet) { create :subnet }
      let(:site) { subnet.site }

      it "allows viewing subnets and its subnets" do
        visit "/sites/#{site.to_param}"

        click_on "View"

        expect(page).to have_content subnet.cidr_block
        expect(page).to have_content subnet.start_address
        expect(page).to have_content subnet.end_address
      end
    end
  end
end
