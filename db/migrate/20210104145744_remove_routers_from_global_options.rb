class RemoveRoutersFromGlobalOptions < ActiveRecord::Migration[6.0]
  def change
    remove_column :global_options, :routers, :string
  end
end
