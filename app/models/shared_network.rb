class SharedNetwork < ApplicationRecord
  has_many :subnets, dependent: :destroy
  belongs_to :site
end
