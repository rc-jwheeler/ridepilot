require "rails_helper"

describe CustomersController do
  before :each do
    @user = create(:role, level: 100).user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in @user
  end

  describe "PUT 'create'" do
    before :each do
      @customer = create(:customer, email: "abc.def.ghi", provider: @user.current_provider)
    end
    
    it "should tell me if a duplicate customer exists" do
      put 'create', customer: @customer.attributes
      request.flash.keys.should include("alert")
      request.flash[:alert].should include('There is already a customer with a similar name or the same email address')
      response.should be_success
    end
  end
end