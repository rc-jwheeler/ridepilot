require "rails_helper"

RSpec.describe CabTripsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/cab_trips").to route_to("cab_trips#index")
    end

    it "does not route to #new" do
      expect(:get => "/cab_trips/new").to_not route_to("cab_trips#new")
    end

    it "does not route to #show" do
      expect(:get => "/cab_trips/1").to_not route_to("cab_trips#show", :id => "1")
    end

    it "does not route to #edit" do
      expect(:get => "/cab_trips/1/edit").to_not route_to("cab_trips#edit", :id => "1")
    end

    it "does not route to #create" do
      expect(:post => "/cab_trips").to_not route_to("cab_trips#create")
    end

    it "does not route to #update" do
      expect(:put => "/cab_trips/1").to_not route_to("cab_trips#update", :id => "1")
    end

    it "does not route to #destroy" do
      expect(:delete => "/cab_trips/1").to_not route_to("cab_trips#destroy", :id => "1")
    end

    it "routes to #edit_multiple" do
      expect(:get => "/cab_trips/edit_multiple").to route_to("cab_trips#edit_multiple")
    end

    it "routes to #update_multiple" do
      expect(:put => "/cab_trips/update_multiple").to route_to("cab_trips#update_multiple")
    end

  end
end
