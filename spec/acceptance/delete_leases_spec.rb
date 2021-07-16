require "rails_helper"

def stub_all_leases(hw_address, ip_address, hostname)
  kea_response =
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

    kea_response_empty =
    [
      {
        "arguments": {
          "leases": []
        },
        "result": 0
      }
    ].to_json

  stub_request(:post, ENV.fetch("KEA_CONTROL_AGENT_URI"))
    .with(body: {
      command: "lease4-get-all",
      service: ["dhcp4"],
      arguments: {subnets: [subnet.kea_id]}
    }, headers: {
      "Content-Type": "application/json"
    })
    .to_return(body: kea_response).times(1).then.
    to_return(body: kea_response_empty)
  end


  def stub_single_lease(hw_address, ip_address, hostname)
    kea_response_lease =
      [
        {
          "arguments": {
            "hostname": hostname,
            "hw-address": hw_address,
            "ip-address": ip_address,
            "state": 0,
            "subnet-id": subnet.kea_id
          },
          "result": 0
        }
      ].to_json

    stub_request(:post, ENV.fetch("KEA_CONTROL_AGENT_URI"))
    .with(body: {
      command: "lease4-get",
      service: ["dhcp4"],
      arguments:{
        "ip-address" => ip_address
      }},
      headers: {
      'Content-Type'=>'application/json'
      })
      .to_return(body: kea_response_lease)

  end

  def stub_destroy_lease(ip_address)
    kea_response_lease_destroyed =
      [
        {
          "result": 0
        }
      ].to_json

    stub_request(:post, ENV.fetch("KEA_CONTROL_AGENT_URI"))
    .with(body: {
      command: "lease4-del",
      service: ["dhcp4"],
      arguments:{
        "ip-address" => ip_address
      }},
      headers: {
      'Content-Type'=>'application/json'
      })
      .to_return(body: kea_response_lease_destroyed)

  end




RSpec.describe "delete leases", type: :feature do
  let(:subnet) { create(:subnet) }

  hw_address = "00:0c:01:02:03:05"
  ip_address = "172.0.0.2"
  hostname   = "test.example.com"

  before do
    stub_all_leases(hw_address, ip_address, hostname)
  end


  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow deleting leases" do
      visit "/subnets/#{subnet.to_param}/leases"

      expect(page).not_to have_content "Delete"
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "delete a lease" do
      visit "/subnets/#{subnet.to_param}/leases"

      stub_single_lease(hw_address, ip_address, hostname)
      click_on "Delete"

      expect(page).to have_content("Are you sure you want to delete this lease?")
      expect(page).to have_content(ip_address)
      expect(page).to have_content(hostname)

      stub_destroy_lease(ip_address)

      click_on "Delete lease"

      expect(page).to have_content("Successfully deleted lease.")
      expect(page).not_to have_content(ip_address)

    end
  end
end
