class CreateOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :options do |t|
      t.string :routers, null: false
      t.string :domain_name_servers, null: false
      t.string :domain_name, null: false
      t.boolean :is_global, default: false

      t.timestamps
    end
  end
end
