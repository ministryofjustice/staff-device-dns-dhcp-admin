class RemoveRoutersFromOptions < ActiveRecord::Migration[6.0]
  def change
    remove_column :options, :routers, :string
  end
end
