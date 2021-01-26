class AddValidLifetimeUnitToGlobalOptions < ActiveRecord::Migration[6.0]
  def change
    add_column :global_options, :valid_lifetime_unit, :string, default: "Seconds"
  end
end
