require "rails_helper"

RSpec.describe "FundingSources", type: :request do
  describe "GET /funding_sources" do
    it "works! (now write some real specs)" do
      get funding_sources_path
      expect(response).to have_http_status(200)
    end
  end
end
