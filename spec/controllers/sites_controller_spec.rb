require "rails_helper"

describe SitesController, type: :controller do
  describe "GET index" do
    before do
      sign_in create(:user, :viewer)
    end

    it "returns sites ordered by fits_id" do
      site1 = create :site, fits_id: "FITS3"
      site2 = create :site, fits_id: "FITS1"
      site3 = create :site, fits_id: "FITS2"

      get :index

      expect(assigns(:sites)).to eq [site2, site3, site1]
    end
  end

  describe "pagination" do
    before do 
      sign_in create(:user, :viewer)
      100.times do |i|
        create :site, fits_id: "FITS#{i+1}"
    end
  end

    let(:per_page) {50}

    it "displays 50 sites per page" do
      first_page_sites = Site.page(1).per(per_page)

      expect(first_page_sites.count).to eq(50)
      expect(first_page_sites.first.fits_id).to eq("FITS1")
      expect(first_page_sites.last.fits_id).to eq("FITS50")
    end

    it 'handles pagination correctly for multiple pages' do
      
      first_page = Site.page(1).per(per_page)
      second_page = Site.page(2).per(per_page)
  
      expect(first_page.count).to eq(50)
      expect(second_page.count).to eq(50)
      
      expect(first_page.last.fits_id).to eq("FITS50")
      expect(second_page.first.fits_id).to eq("FITS51")
    end
  end


  describe "GET show" do
    before do
      sign_in create(:user, :viewer)
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
