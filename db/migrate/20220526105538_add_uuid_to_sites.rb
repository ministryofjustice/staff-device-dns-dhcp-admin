class AddUuidToSites < ActiveRecord::Migration[7.0]
  def change
    add_column :sites, :uuid, :string, null: false, unique: true
  end
end
