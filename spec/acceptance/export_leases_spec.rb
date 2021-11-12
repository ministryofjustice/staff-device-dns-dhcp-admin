require "rails_helper"

RSpec.describe "Listing leases", type: :feature do

  let(:user) { create :user, :editor }
  let(:subnet) { create(:subnet) }

  let(:hw_address) { "00-0c-01-02-03-05" }
  let(:formatted_hw_address) { "00:0c:01:02:03:05" }
  let(:ip_address) { "172.0.0.2" }
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

  let(:csv_string)  { "00-0c-01-02-03-05,172.0.0.2,test.example.com,0" }
  let(:csv_options) { {filename: "#{subnet.start_address}.csv", disposition: 'attachment', type: 'text/csv; charset=utf-8; header=present'} }

  it "exports the list of leases to a csv" do
    visit "/subnets/#{subnet.to_param}/leases"
    click_on "Export"

    expect(LeasesController.export).to receive(:send_data).with(csv_string, csv_options) {
      @controller.render nothing: true # to prevent a 'missing template' error
    }

    # HW address,IP address,Hostname,State
    # 00-0c-01-02-03-05,172.0.0.2,test.example.com,0
    
    # this creates the resulting file in memory 
    # we compare this to a known desired csv in /spec/lib/data 
  end

end