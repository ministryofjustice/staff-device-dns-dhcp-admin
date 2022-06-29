class PopulateSubnetReservationsCount < ActiveRecord::Migration[7.0]
  def change
    Subnet.find_each do |subnet|
      Subnet.reset_counters(subnet.id, :reservations)
    end
  end
end
