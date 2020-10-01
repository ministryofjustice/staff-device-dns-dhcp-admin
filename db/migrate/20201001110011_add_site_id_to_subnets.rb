class AddSiteIdToSubnets < ActiveRecord::Migration[6.0]
  def change
    add_reference :subnets, :site, foreign_key: true, null: false
  end
end
