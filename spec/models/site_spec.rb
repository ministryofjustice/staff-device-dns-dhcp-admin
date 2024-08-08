require "rails_helper"

RSpec.describe Site, type: :model do
  subject { build :site }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :fits_id }
  it { is_expected.to validate_uniqueness_of(:fits_id).case_insensitive }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  it "expects model to have a valid uuid" do
    site = Site.create(fits_id: "FITS_0005", name: "Test Site 0005")
    expect(site.uuid.length).to eq(36)
  end

  it "does not create a uuid if its already there" do
    site = Site.create(fits_id: "FITS_0005", name: "Test Site 0005", uuid: "3dc6c608-992f-4190-8808-4eab8c0cb03d")
    site.save!
    expect(site.reload.uuid).to eq("3dc6c608-992f-4190-8808-4eab8c0cb03d")
  end

  it "defaults windows_update_delivery_optimisation_enabled? to False" do
    site = Site.create(fits_id: "FITS_0005", name: "Test Site 0005")
    expect(site.windows_update_delivery_optimisation_enabled?).to be false
  end
end
