require "rails_helper"

describe UseCases::GenerateKeaConfig do
  describe "#execute" do
    context "default config" do
      it "returns a default subnet used for smoke testing" do
        config = UseCases::GenerateKeaConfig.new.execute

        expect(config[:Dhcp4]).to include(subnet4: [
          {
            pools: [
              {
                pool: "172.0.0.1 - 172.0.2.0"
              }
            ],
            subnet: "127.0.0.1/0",
            id: 1
          }
        ])
      end
    end
  end
end
