class CreateSharedNetwork < ActiveRecord::Migration[6.1]
  def change
    unless ENV['SENTRY_CURRENT_ENV'] == "development"
      create_table :shared_networks do |t|
        t.timestamps
      end

      add_reference :shared_networks, :site, index: true, foreign_key: true
      add_reference :subnets, :shared_network, index: true, foreign_key: true
    end

    Subnet.find_each do |subnet|
      shared_network = SharedNetwork.create!(site_id: subnet.site_id)
      subnet.update!(shared_network_id: shared_network.id)
    end

    remove_reference :subnets, :site, index: true, foreign_key: true
  end
end
