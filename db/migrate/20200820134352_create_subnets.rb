class CreateSubnets < ActiveRecord::Migration[6.0]
  def change
    create_table :subnets do |t|
      t.string :cidr_block, null: false
      t.string :start_address, null: false
      t.string :end_address, null: false

      t.timestamps
    end
  end
end



