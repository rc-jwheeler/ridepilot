require "rails_helper"

RSpec.describe "API::V1::customers" do

  context "User authentication" do

    it "returns 403 when not passing user token in request header" do
      get api_v1_authenticate_customer_path
      expect(response.status).to be(403)
    end

    it "returns 401 when not passing invalid user token in request header" do
      get api_v1_authenticate_customer_path, nil, {"X-RIDEPILOT-TOKEN" => SecureRandom.uuid}
      expect(response.status).to be(401)
    end   

  end

  context "Customer authentication" do 

    it "returns 200 when passing valid user token and customer params" do 
      customer = create(:customer)
      booking_user = create(:booking_user, url: "http://localhost:3000")
      get api_v1_authenticate_customer_path, {
        customer_id: customer.id, 
        customer_token: customer.token,
        provider_id: customer.provider_id
        }, {
        "X-RIDEPILOT-TOKEN" => booking_user.token
      }
      
      expect(response.body).to match("{}")
      expect(response.status).to be(200)
    end
  end

end