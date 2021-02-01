class RemoveDefaultFromGlobalOptionsValidLifetimeUnit < ActiveRecord::Migration[6.0]
  def change
    change_column_default :global_options, :valid_lifetime_unit, from: "Seconds", to: nil
  end
end
