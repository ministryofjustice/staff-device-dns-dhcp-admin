class MakeClientClassClientIdUnique < ActiveRecord::Migration[6.0]
  def change
    add_index :client_classes, :client_id, unique: true
  end
end
