require "rails_helper"

RSpec.describe VehicleMaintenanceEventsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/vehicle_maintenance_events").to route_to("vehicle_maintenance_events#index")
    end

    it "routes to #new" do
      expect(:get => "/vehicle_maintenance_events/new").to route_to("vehicle_maintenance_events#new")
    end

    it "routes to #edit" do
      expect(:get => "/vehicle_maintenance_events/1/edit").to route_to("vehicle_maintenance_events#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/vehicle_maintenance_events").to route_to("vehicle_maintenance_events#create")
    end

    it "routes to #update" do
      expect(:put => "/vehicle_maintenance_events/1").to route_to("vehicle_maintenance_events#update", :id => "1")
    end

  end
end
