class UsersController < Devise::SessionsController
  # GET /resource/sign_in
  def new
    if User.count == 0
      return redirect_to :action=>:show_init
    end
    super
  end
end
