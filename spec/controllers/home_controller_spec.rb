require "rails_helper"

RSpec.describe HomeController, type: :controller do
  login_admin_as_current_user

  describe "GET #index" do
    it "should be successful" do
      get 'index'
      expect(response).to be_success
    end
  end
end
