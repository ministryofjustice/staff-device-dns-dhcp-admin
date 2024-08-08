class SharedNetwork < ApplicationRecord
  has_many :subnets, dependent: :destroy
  belongs_to :site

  def name
    "#{site.fits_id}-#{id}"
  end
end
