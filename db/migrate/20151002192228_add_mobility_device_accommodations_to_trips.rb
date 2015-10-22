class AddMobilityDeviceAccommodationsToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :mobility_device_accommodations, :integer
  end
end
