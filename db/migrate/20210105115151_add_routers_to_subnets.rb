class AddRoutersToSubnets < ActiveRecord::Migration[6.0]
  def change
    add_column :subnets, :routers, :string, null: false, default: "127.0.0.1"
  end
end
