class CreateSubnets < ActiveRecord::Migration[6.0]
  def change
    create_table :subnets do |t|
      t.string :cidr_block
      t.string :start_address
      t.string :end_address

      t.timestamps
    end
  end
end
