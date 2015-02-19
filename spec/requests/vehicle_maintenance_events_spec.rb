require "rails_helper"

RSpec.describe "VehicleMaintenanceEvents", type: :request do
  describe "GET /vehicle_maintenance_events" do
    it "works! (now write some real specs)" do
      get vehicle_maintenance_events_path
      expect(response).to have_http_status(200)
    end
  end
end
