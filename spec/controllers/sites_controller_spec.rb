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
      subnet2 = create :subnet, start_address: "10.1.3.1", end_address: "10.1.3.100", cidr_block: "10.1.3.0/24", site: subnet1.site
      subnet3 = create :subnet, start_address: "10.1.10.1", end_address: "10.1.10.100", cidr_block: "10.1.10.0/24", site: subnet1.site

      get :show, params: {id: subnet1.site_id}

      expect(assigns(:subnets)).to eq [subnet2, subnet3, subnet1]
    end
  end
end
