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

        stub_subnet_leases_api_request(subnet.kea_id, [])
        stub_subnet_leases_api_request(subnet2.kea_id, [])
        stub_subnet_leases_api_request(subnet3.kea_id, [])

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
        leases_json = [
          {
            "hw-address": "01:16:ed:54:9d:92",
            "ip-address": "192.168.0.10",
            "hostname": "whatever.local",
            "state": 0
          }
        ]

        stub_subnet_leases_api_request(subnet.kea_id, leases_json)

        visit "/sites/#{site.to_param}"

        first_subnet = page.find("#subnets")
        # expect(first_subnet.find(".num_reserved_ips")).to have_content("0")
        expect(first_subnet.find(".num_remaining_ips"))
          .to have_content(subnet.total_addresses - leases_json.length)
        # expect(first_subnet.find(".percentage_used")).to have_content("50%")
      end
    end
  end

  def stub_subnet_leases_api_request(subnet_kea_id, leases_json)
    stub_request(:post, ENV["KEA_CONTROL_AGENT_URI"])
      .with(
        body: {
          command: "lease4-get-all",
          service: ["dhcp4"],
          arguments: {
            subnets: [subnet_kea_id]
          }
        }.to_json,
        headers: {
          'Content-Type'=>'application/json'
        }
      ).to_return(body: [
        {
          "arguments": {
            "leases": leases_json
          },
          "result": 0
        }
      ].to_json)
  end
end
