class ChangeZoneForwardersToCommaSeparated < ActiveRecord::Migration[6.0]
  def up
    Zone.find_each do |zone|
      zone.forwarders = zone[:forwarders].split(";").join(",")
      zone.save!
    end
  end

  def down
    Zone.find_each do |zone|
      zone.forwarders = zone[:forwarders].split(",").join(";") + ";"
      zone.save(validate: false)
    end
  end
end
