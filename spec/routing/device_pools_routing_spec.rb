require "rails_helper"

RSpec.describe DevicePoolsController, type: :routing do
  describe "routing" do

    it "does not route to #index" do
      expect(:get => "/device_pools").to_not route_to("device_pools#index")
    end

    it "routes to #new" do
      expect(:get => "/device_pools/new").to route_to("device_pools#new")
    end

    it "routes to #show" do
      expect(:get => "/device_pools/1").to route_to("device_pools#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/device_pools/1/edit").to route_to("device_pools#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/device_pools").to route_to("device_pools#create")
    end

    it "routes to #update" do
      expect(:put => "/device_pools/1").to route_to("device_pools#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/device_pools/1").to route_to("device_pools#destroy", :id => "1")
    end

  end
end
