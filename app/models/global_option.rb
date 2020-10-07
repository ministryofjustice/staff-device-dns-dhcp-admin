class GlobalOption < ApplicationRecord
  validates :routers, :domain_name_servers, :domain_name, presence: true
end
