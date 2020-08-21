require "rails_helper"

describe SubnetsController, type: :controller do
  describe "GET index" do
    before do
      sign_in User.create!
    end

    it "returns subnets ordered by cidr_block" do
      subnet1 = create :subnet, cidr_block: "10.0.12.0/24"
      subnet2 = create :subnet, cidr_block: "10.0.3.0/24"
      subnet3 = create :subnet, cidr_block: "10.0.10.0/24"

      get :index

      expect(assigns(:subnets)).to eq [subnet2, subnet3, subnet1]
    end
  end
end
