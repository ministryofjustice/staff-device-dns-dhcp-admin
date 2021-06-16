class Exclusion < ApplicationRecord
    belongs_to :subnet

    validates :subnet, presence: true
    validates :start_address, presence: true
    validates :end_address, presence: true

    audited
end
