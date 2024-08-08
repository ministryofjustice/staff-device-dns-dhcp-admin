require "rails_helper"

describe "delete subnets", type: :feature do
  let(:subnet) do
    Audited.audit_class.as_user(editor) do
      create(:subnet, :with_reservation, :with_option)
    end
  end

  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "delete a subnet" do
    stub_subnet_leases_api_request(subnet.kea_id, [])
    visit "/sites/#{subnet.site.to_param}"

    click_on "Delete"

    expect(page).to have_content("Are you sure you want to delete this subnet?")
    expect(page).to have_content(subnet.cidr_block)

    expect_config_to_be_verified
    expect_config_to_be_published

    click_on "Delete subnet"

    expect(page).to have_content("Successfully deleted subnet")
    expect(page).to have_content("This could take up to 10 minutes to apply.")
    expect(page).not_to have_content(subnet.cidr_block)

    expect_audit_log_entry_for(editor.email, "destroy", "Subnet")
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
