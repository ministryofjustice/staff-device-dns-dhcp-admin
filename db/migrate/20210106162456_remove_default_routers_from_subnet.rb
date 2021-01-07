class RemoveDefaultRoutersFromSubnet < ActiveRecord::Migration[6.0]
  def change
    change_column_default :subnets, :routers, from: "127.0.0.1", to: nil
  end
end
