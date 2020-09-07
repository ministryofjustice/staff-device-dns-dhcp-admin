class Zone < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :forwarders, presence: true
end
