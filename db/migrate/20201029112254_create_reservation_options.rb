class CreateReservationOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :reservation_options do |t|
      t.string :domain_name
      t.string :routers
      t.references :reservation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
