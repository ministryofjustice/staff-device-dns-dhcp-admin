class CreateClientClasses < ActiveRecord::Migration[6.0]
  def change
    create_table :client_classes do |t|
      t.string :name, null: false
      t.string :client_id, null: false
      t.string :domain_name_servers, null: false
      t.string :domain_name, null: false

      t.timestamps
    end
  end
end
