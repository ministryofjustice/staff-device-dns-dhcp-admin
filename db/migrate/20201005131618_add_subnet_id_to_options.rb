class AddSubnetIdToOptions < ActiveRecord::Migration[6.0]
  def change
    add_reference :options, :subnet, foreign_key: true, null: true
  end
end
