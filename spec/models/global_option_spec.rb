require "rails_helper"

RSpec.describe GlobalOption, type: :model do
  subject { build :global_option }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :routers }
  it { is_expected.to validate_presence_of :domain_name_servers }
  it { is_expected.to validate_presence_of :domain_name }
end
