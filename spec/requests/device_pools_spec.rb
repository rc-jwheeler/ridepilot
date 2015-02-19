require "rails_helper"

RSpec.describe "DevicePools", type: :request do
  describe "GET /device_pools" do
    it "works! (now write some real specs)" do
      get device_pools_path
      expect(response).to have_http_status(200)
    end
  end
end
