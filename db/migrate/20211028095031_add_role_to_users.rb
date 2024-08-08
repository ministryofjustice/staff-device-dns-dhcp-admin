class AddRoleToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :role, :integer, null: false, default: 0
    User.where(editor: true).update_all(role: 2) # 2 will be our editor role
  end
end
