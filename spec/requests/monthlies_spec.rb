require "rails_helper"

RSpec.describe "Monthlies", type: :request do
  describe "GET /monthlies" do
    it "works! (now write some real specs)" do
      get monthlies_path
      expect(response).to have_http_status(200)
    end
  end
end
