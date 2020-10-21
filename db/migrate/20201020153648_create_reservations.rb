class CreateReservations < ActiveRecord::Migration[6.0]
  def change
    create_table :reservations do |t|
      t.references :subnet, null: false, foreign_key: true
      t.string :hw_address
      t.string :ip_address
      t.string :hostname
      t.string :description

      t.timestamps
    end
  end
end
