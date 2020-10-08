class MakeOptionFieldsNullable < ActiveRecord::Migration[6.0]
  def change
    change_column_null :options, :routers, true
    change_column_null :options, :domain_name_servers, true
    change_column_null :options, :domain_name, true
  end
end
