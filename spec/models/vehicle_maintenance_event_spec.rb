require "rails_helper"

RSpec.describe VehicleMaintenanceEvent, type: :model do
  it "requires a vehicle" do
    maintenance = build :vehicle_maintenance_event, vehicle: nil
    expect(maintenance.valid?).to be_falsey
    expect(maintenance.errors.keys).to include :vehicle
  end
end
