class RemoveGlobalFromOptions < ActiveRecord::Migration[6.0]
  def up
    Option.where(global: true).destroy_all

    remove_column :options, :global
  end

  def down
    add_column :options, :global, :boolean, default: false

    Option.find_or_create_by(global: true) do |option|
      option.routers = ["192.1.1.10", "192.1.1.12"]
      option.domain_name_servers = ["192.1.2.10", "192.1.2.12"]
      option.domain_name = "seeds.example.com"
    end
  end
end
