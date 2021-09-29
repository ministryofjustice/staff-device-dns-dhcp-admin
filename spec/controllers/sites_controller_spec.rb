require "rails_helper"

describe SitesController, type: :controller do
  describe "GET index" do
    before do
      sign_in create(:user, :reader)
    end

    it "returns sites ordered by fits_id" do
      site1 = create :site, fits_id: "FITS3"
      site2 = create :site, fits_id: "FITS1"
      site3 = create :site, fits_id: "FITS2"

      get :index

      expect(assigns(:sites)).to eq [site2, site3, site1]
    end
  end

  describe "GET show" do
    before do
      sign_in create(:user, :reader)
    end

    it "returns subnets ordered by cidr_block" do
      subnet1 = create :subnet, start_address: "10.1.12.1", end_address: "10.1.12.100", cidr_block: "10.1.12.0/24"
      subnet2 = create :subnet, start_address: "10.1.3.1", end_address: "10.1.3.100", cidr_block: "10.1.3.0/24", shared_network: subnet1.shared_network
      subnet3 = create :subnet, start_address: "10.1.10.1", end_address: "10.1.10.100", cidr_block: "10.1.10.0/24", shared_network: subnet1.shared_network

      stub_subnet_leases_api_request(subnet1.kea_id, [])
      stub_subnet_leases_api_request(subnet2.kea_id, [])
      stub_subnet_leases_api_request(subnet3.kea_id, [])

      get :show, params: {id: subnet1.site.id}

      expect(assigns(:subnets)).to eq [subnet2, subnet3, subnet1]
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
