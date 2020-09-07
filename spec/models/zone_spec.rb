require 'rails_helper'

RSpec.describe Zone, type: :model do
  subject { build :zone }

  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :forwarders }
end
