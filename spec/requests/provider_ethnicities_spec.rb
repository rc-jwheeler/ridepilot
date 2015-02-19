require "rails_helper"

RSpec.describe "ProviderEthnicities", type: :request do
  describe "GET /provider_ethnicities" do
    it "works! (now write some real specs)" do
      get provider_ethnicities_path
      expect(response).to have_http_status(200)
    end
  end
end
