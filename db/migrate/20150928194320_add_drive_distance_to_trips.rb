class AddDriveDistanceToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :drive_distance, :float
  end
end
