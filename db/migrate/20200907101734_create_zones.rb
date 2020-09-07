class CreateZones < ActiveRecord::Migration[6.0]
  def change
    create_table :zones do |t|
      t.string :name, unique: true, null: false
      t.string :forwarders, null: false
      t.string :purpose

      t.timestamps
    end
  end
end
