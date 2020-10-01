require "rails_helper"

describe SitesController, type: :controller do
  describe "GET index" do
    before do
      sign_in User.create!
    end

    it "returns sites ordered by fits_id" do
      site1 = create :site, fits_id: "FITS3"
      site2 = create :site, fits_id: "FITS1"
      site3 = create :site, fits_id: "FITS2"

      get :index

      expect(assigns(:sites)).to eq [site2, site3, site1]
    end
  end
end
