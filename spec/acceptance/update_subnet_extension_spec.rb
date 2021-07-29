require "rails_helper"

describe "updating a subnet extension", type: :feature do
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "extends the subnet with another pre existing subnet" do
    subnet = Audited.audit_class.as_user(editor) { create :subnet }
    other_subnet = Audited.audit_class.as_user(editor) do
      create :subnet, shared_network: create(:shared_network, site: subnet.shared_network.site)
    end

    visit "/subnets/#{subnet.to_param}"

    click_on "Add a subnet to this shared network"

    select other_subnet.cidr_block, from: "Subnet"

    expect_config_to_be_verified
    expect_config_to_be_published

    click_button "Add to shared network"

    expect(page).to have_content(other_subnet.cidr_block)
    expect(page).to have_content(other_subnet.start_address)
    expect(page).to have_content(other_subnet.end_address)
    expect(page).to have_content(other_subnet.routers.join(", "))

    expect_audit_log_entry_for(editor.email, "update", "Subnet")
  end

  it "deletes the original shared network when assigned a new one" do
    subnet = Audited.audit_class.as_user(editor) { create :subnet }
    other_subnet = Audited.audit_class.as_user(editor) do
      create :subnet, shared_network: create(:shared_network, site: subnet.shared_network.site)
    end

    visit "/subnets/#{subnet.to_param}"

    click_on "Add a subnet to this shared network"

    select other_subnet.cidr_block, from: "Subnet"

    expect_config_to_be_verified
    expect_config_to_be_published


    expect(subnet.shared_network).not_to eq(other_subnet.shared_network)

    click_button "Add to shared network"

    expect(SharedNetwork.find_by(id: other_subnet.shared_network.id)).to eq(nil)

    other_subnet.reload
    subnet.reload
    expect(subnet.shared_network).to eq(other_subnet.shared_network)
  end
end
