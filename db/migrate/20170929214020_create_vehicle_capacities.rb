class CreateVehicleCapacities < ActiveRecord::Migration
  def change
    create_table :vehicle_capacities do |t|
      t.references :capacity_type, index: true
      t.integer :capacity
      t.references :vehicle_type, index: true

      t.timestamps
    end
  end
end
