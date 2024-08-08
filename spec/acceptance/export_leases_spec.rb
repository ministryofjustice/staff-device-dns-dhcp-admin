require "rails_helper"

RSpec.describe "Exporting leases to .csv", type: :feature do
  let(:user) { create :user, :editor }
  let(:subnet) { create(:subnet) }

  let(:hw_address) { "00-0c-01-02-03-05" }
  let(:formatted_hw_address) { "00:0c:01:02:03:05" }
  let(:ip_address) { subnet.end_address.to_s }
  let(:hostname) { "test.example.com" }

  let(:kea_response) do
    [
      {
        arguments: {
          leases: [
            {
              "hw-address": hw_address,
              "ip-address": ip_address,
              hostname: hostname,
              state: 0
            }
          ]
        },
        result: 0
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

  it "exports the list of leases to a csv" do
    visit "/subnets/#{subnet.to_param}/leases"
    click_on "Export"

    expect(response_headers["Content-Disposition"])
      .to have_content "attachment"

    expect(response_headers["Content-Disposition"])
      .to have_content "#{subnet.start_address}.csv"

    expect(body).to eq <<~CSV
      HW address,IP address,Hostname,State
      00-0c-01-02-03-05,#{subnet.end_address},test.example.com,0
    CSV
  end
end
