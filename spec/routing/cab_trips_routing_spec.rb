require "rails_helper"

RSpec.describe CabTripsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/cab_trips").to route_to("cab_trips#index")
    end

    it "routes to #edit_multiple" do
      expect(:get => "/cab_trips/edit_multiple").to route_to("cab_trips#edit_multiple")
    end

    it "routes to #update_multiple" do
      expect(:put => "/cab_trips/update_multiple").to route_to("cab_trips#update_multiple")
    end

  end
end
