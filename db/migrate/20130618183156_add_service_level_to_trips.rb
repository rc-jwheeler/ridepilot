class AddServiceLevelToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :service_level, :string
  end

  def self.down
    remove_column :trips, :service_level
  end
end
