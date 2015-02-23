module ControllerMacros
  def login_admin_as_current_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @current_user = create(:admin)
      sign_in @current_user
    end
  end

  def login_super_admin_as_current_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @current_user = create(:super_admin)
      sign_in @current_user
    end
  end
end
