class AddReservationsCountToSubnets < ActiveRecord::Migration[7.0]
  def change
    add_column :subnets, :reservations_count, :integer, default: 0
  end
end
