require "rails_helper"

RSpec.describe "DevicePoolDrivers", type: :request do
  describe "GET /device_pool_drivers" do
    it "works! (now write some real specs)" do
      get device_pool_drivers_path
      expect(response).to have_http_status(200)
    end
  end
end
