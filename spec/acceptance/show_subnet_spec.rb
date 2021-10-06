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

      it "allows viewing subnets" do
        stub_subnet_leases_api_request(subnet.kea_id, [])
        visit "/sites/#{site.to_param}"

        click_on "View"

        expect(page).to have_content subnet.cidr_block
        expect(page).to have_content subnet.start_address
        expect(page).to have_content subnet.end_address
      end

      it "should only show shared network table if sharing one with another subnet" do
        visit "/subnets/#{subnet.to_param}"

        expect(page).to have_no_content("List of subnets")
      end

      it "allows viewing other subnets in the same shared network" do
        other_subnet = create(:subnet, shared_network: subnet.shared_network)
        visit "/subnets/#{subnet.to_param}"

        expect(page).to have_content other_subnet.cidr_block
        expect(page).to have_content other_subnet.start_address
        expect(page).to have_content other_subnet.end_address
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
          "Content-Type" => "application/json"
        }
      ).to_return(body: [
        {
          arguments: {
            leases: leases_json
          },
          result: 0
        }
      ].to_json)
  end
end
