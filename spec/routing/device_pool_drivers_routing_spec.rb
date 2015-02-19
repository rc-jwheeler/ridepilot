require "rails_helper"

RSpec.describe DevicePoolDriversController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/device_pool_drivers").to route_to("device_pool_drivers#index")
    end

    it "routes to #new" do
      expect(:get => "/device_pool_drivers/new").to route_to("device_pool_drivers#new")
    end

    it "routes to #show" do
      expect(:get => "/device_pool_drivers/1").to route_to("device_pool_drivers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/device_pool_drivers/1/edit").to route_to("device_pool_drivers#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/device_pool_drivers").to route_to("device_pool_drivers#create")
    end

    it "routes to #update" do
      expect(:put => "/device_pool_drivers/1").to route_to("device_pool_drivers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/device_pool_drivers/1").to route_to("device_pool_drivers#destroy", :id => "1")
    end

  end
end
