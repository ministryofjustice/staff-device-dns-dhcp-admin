class AddValidLifetimeToGlobalOptions < ActiveRecord::Migration[6.0]
  def change
    add_column :global_options, :valid_lifetime, :integer, unsigned: true
  end
end
