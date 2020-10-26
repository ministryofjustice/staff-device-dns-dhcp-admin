class AddValidLifetimeToOptions < ActiveRecord::Migration[6.0]
  def change
    add_column :options, :valid_lifetime, :integer, unsigned: true
  end
end
