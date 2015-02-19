require "rails_helper"

RSpec.describe V1::DevicePoolDriversController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:post => "https://test.host/device_pool_drivers.json").to route_to("v1/device_pool_drivers#index", :protocol => "https://", :format => "json")
    end

    it "routes to #update" do
      expect(:post => "https://test.host/v1/device_pool_drivers/1.json").to route_to("v1/device_pool_drivers#update", :protocol => "https://", :format => "json", :id => "1")
    end

  end
end
