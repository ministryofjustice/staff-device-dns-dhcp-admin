require 'rails_helper'

RSpec.describe Exclusion, type: :model do
  subject { build :exclusion }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :subnet }

  it { is_expected.to validate_presence_of :start_address }
  it { is_expected.to validate_presence_of :end_address }
end
