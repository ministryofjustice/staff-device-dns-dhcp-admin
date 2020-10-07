class CreateGlobalOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :global_options do |t|
      t.string :routers, null: false
      t.string :domain_name_servers, null: false
      t.string :domain_name, null: false

      t.timestamps
    end
  end
end
