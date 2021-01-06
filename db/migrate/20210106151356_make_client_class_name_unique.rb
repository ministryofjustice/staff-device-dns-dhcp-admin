class MakeClientClassNameUnique < ActiveRecord::Migration[6.0]
  def change
    add_index :client_classes, :name, unique: true
  end
end
