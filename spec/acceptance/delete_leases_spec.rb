require "rails_helper"

RSpec.describe "delete leases", type: :feature do
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

      click_on "Delete"

      expect(page).to have_content("Are you sure you want to delete this lease?")
      expect(page).to have_content(lease.ip_address)
      expect(page).to have_content(lease.hostname)

      expect_config_to_be_verified
      expect_config_to_be_published

      click_on "Delete lease"

      expect(page).to have_content("Successfully deleted lease.")
      expect(page).not_to have_content(lease.ip_address)

      # expect_audit_log_entry_for(editor.email, "destroy", "lease")
    end
  end
end
