require "rails_helper"

RSpec.describe DevicePoolDriversController, type: :routing do
  describe "routing" do

    it "does not route to #index" do
      expect(:get => "/device_pools/1/device_pool_drivers").to_not route_to("device_pool_drivers#index", :device_pool_id => "1")
    end

    it "does not route to #new" do
      expect(:get => "/device_pools/1/device_pool_drivers/new").to_not route_to("device_pool_drivers#new", :device_pool_id => "1")
    end

    it "does not route to #show" do
      expect(:get => "/device_pools/1/device_pool_drivers/1").to_not route_to("device_pool_drivers#show", :device_pool_id => "1", :id => "1")
    end

    it "does not route to #edit" do
      expect(:get => "/device_pools/1/device_pool_drivers/1/edit").to_not route_to("device_pool_drivers#edit", :device_pool_id => "1", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/device_pools/1/device_pool_drivers").to route_to("device_pool_drivers#create", :device_pool_id => "1")
    end

    it "does not route to #update" do
      expect(:put => "/device_pools/1/device_pool_drivers/1").to_not route_to("device_pool_drivers#update", :device_pool_id => "1", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/device_pools/1/device_pool_drivers/1").to route_to("device_pool_drivers#destroy", :device_pool_id => "1", :id => "1")
    end

  end
end
