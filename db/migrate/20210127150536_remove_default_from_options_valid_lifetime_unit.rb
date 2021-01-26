class RemoveDefaultFromOptionsValidLifetimeUnit < ActiveRecord::Migration[6.0]
  def change
    change_column_default :options, :valid_lifetime_unit, from: "Seconds", to: nil
  end
end
