class AddValidLifetimeUnitToOptions < ActiveRecord::Migration[6.0]
  def change
    add_column :options, :valid_lifetime_unit, :string, default: "Seconds"
  end
end
