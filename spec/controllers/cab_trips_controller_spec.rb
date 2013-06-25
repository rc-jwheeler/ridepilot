require 'spec_helper'

describe CabTripsController do
  before :each do
    @user = create_role(level: 100).user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in @user
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'edit_multiple'" do
    it "should be successful" do
      get 'edit_multiple'
      response.should be_success
    end
  end
  
  describe "PUT 'update_multiple'" do
    pending "Need some tests here"
  end
end