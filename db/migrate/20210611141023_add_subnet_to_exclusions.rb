class AddSubnetToExclusions < ActiveRecord::Migration[6.1]
  def change
    add_reference :exclusions, :subnet, null: false, foreign_key: true
  end
end
