class AddEditorToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :editor, :boolean, default: false
  end
end
