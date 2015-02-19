require "rails_helper"

RSpec.describe DevicePoolDriversController, type: :routing do
  describe "routing" do

    it "routes to #create" do
      expect(:post => "/device_pools/1/device_pool_drivers").to route_to("device_pool_drivers#create", :device_pool_id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/device_pools/1/device_pool_drivers/2").to route_to("device_pool_drivers#destroy", :device_pool_id => "1", :id => "2")
    end

  end
end
