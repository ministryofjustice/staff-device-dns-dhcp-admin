class CreateExclusions < ActiveRecord::Migration[6.1]
  def change
    create_table :exclusions do |t|
      t.string :start_address
      t.string :end_address

      t.timestamps
    end
  end
end
