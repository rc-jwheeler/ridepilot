class AddMobilityDeviceAccomomdationsToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :mobility_device_accommodations, :integer
  end
end
