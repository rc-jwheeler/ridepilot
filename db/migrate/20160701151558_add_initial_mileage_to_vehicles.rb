class AddInitialMileageToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :initial_mileage, :integer, default: 0
  end
end
