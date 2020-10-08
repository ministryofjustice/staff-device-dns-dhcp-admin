class MakeOptionsSubnetIdNotNullable < ActiveRecord::Migration[6.0]
  def change
    change_column_null :options, :subnet_id, false
  end
end
