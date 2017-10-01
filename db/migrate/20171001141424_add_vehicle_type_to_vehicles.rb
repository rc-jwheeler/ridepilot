class AddVehicleTypeToVehicles < ActiveRecord::Migration
  def change
    add_reference :vehicles, :vehicle_type, index: true
  end
end
