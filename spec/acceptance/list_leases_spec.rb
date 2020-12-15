require "rails_helper"

RSpec.describe "Listing leases", type: :feature do
  let(:user) { create :user, :editor }
  let(:subnet) { create(:subnet) }

  let(:hw_address) { "00:0c:01:02:03:05" }
  let(:ip_address) { "172.0.0.2" }
  let(:hostname) { "test.example.com" }

  let(:kea_response) do
    [
      {
        "arguments": {
          "leases": [
            {
              "hw-address": hw_address,
              "ip-address": ip_address,
              "hostname": hostname,
              "state": 0
            }
          ]
        },
        "result": 0
      }
    ].to_json
  end

  before do
    login_as user

    stub_request(:post, ENV.fetch("KEA_CONTROL_AGENT_URI"))
      .with(body: {
        command: "lease4-get-all",
        service: ["dhcp4"],
        arguments: {subnets: [subnet.kea_id]}
      }, headers: {
        "Content-Type": "application/json"
      })
      .to_return(body: kea_response)
  end

  it "displays a list of leases" do
    visit "/subnets/#{subnet.to_param}"
    click_on "View leases"

    expect(page).to have_content hw_address
    expect(page).to have_content ip_address
    expect(page).to have_content hostname
    expect(page).to have_content "Leased"
  end
end
