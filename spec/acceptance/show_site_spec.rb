require "rails_helper"

describe "showing a site", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing sites" do
      visit "/sites/nonexistant-site-id"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when the site exists" do
      let!(:site) { create :site }
      let!(:shared_network) { create :shared_network, site: site }
      let!(:subnet) { create :subnet, index: 1, shared_network: shared_network }

      it "allows viewing sites and its subnets" do
        subnet2 = create :subnet, index: 2, shared_network: shared_network 
        subnet3 = create :subnet, index: 3 

        visit "/dhcp"

        click_on "View", match: :first

        expect(page).to have_content site.fits_id
        expect(page).to have_content site.name

        expect(page).to have_content subnet.cidr_block
        expect(page).to have_content subnet.start_address
        expect(page).to have_content subnet.end_address

        expect(page).to have_content subnet2.cidr_block

        expect(page).not_to have_content subnet3.cidr_block
      end

      it "shows data about each subnet" do
        stub_request(:post, ENV.fetch("KEA_CONTROL_AGENT_URI"))
          .with(body: {
            command: "stat-lease4-get",
            service: ["dhcp4"]
          }, headers: {
            "Content-Type": "application/json"
          })
          .to_return(body: [
            {
              "result": 0,
              "arguments": {
                "result-set": {
                  "columns": [ "subnet-id",
                                "total-addresses",
                                "cumulative-assigned-addresses",
                                "assigned-addresses",
                                "declined-addresses" ],
                  "rows": [
                    [ 1, 200, 100, 100, 0 ]
                  ]
                }
              }
            }
          ].to_json)

        visit "/sites/#{site.to_param}"

        first_subnet = page.find("#subnets")
        # expect(first_subnet.find(".num_reserved_ips")).to have_content("0")
        expect(first_subnet.find(".num_remaining_ips")).to have_content("100")
        expect(first_subnet.find(".percentage_used")).to have_content("50%")
      end
    end
  end
end
