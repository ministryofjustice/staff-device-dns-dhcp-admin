class AddDeliveryOptimisationEnabledToSites < ActiveRecord::Migration[7.0]
  def change
    add_column :sites, :windows_update_delivery_optimisation_enabled, :bool, default: false
  end
end
