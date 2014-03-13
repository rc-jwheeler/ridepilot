class UsersController < Devise::SessionsController
  require 'new_user_mailer'

  def new
    #hooked up to sign_in
    if User.count == 0
      return redirect_to :action=>:show_init
    end
  end

  def new_user
    if User.count == 0
      return redirect_to :init
    end
    authorize! :edit, current_user.current_provider
    @user = User.new
    @errors = []
  end

  def create_user
    authorize! :edit, current_user.current_provider
    
    #this user might already be a member of the site, but not of this
    #provider, in which case we ought to just set up the role
    @user = User.find_by_email(params[:user][:email])
    @role = Role.new
    new_password = nil
    new_user = false
    record_valid = false
    User.transaction do
      begin
        if not @user
          @user = User.new(params[:user])
          new_password = User.generate_password
          @user.password = new_password
          @user.reset_password_token = User.reset_password_token
          @user.current_provider_id = current_provider_id
          @user.save!
          new_user = true
        end

        @role.user = @user
        @role.provider_id = current_provider_id
        @role.level = params[:role][:level]
        @role.save!

        record_valid = true
      rescue => e
        Rails.logger.info(e)
        raise ActiveRecord::Rollback
      end
    end

    if record_valid
      NewUserMailer.new_user_email(@user, new_password).deliver if new_user
      flash[:notice] = "%s has been added and a password has been emailed" % @user.email
      redirect_to provider_path(current_provider)
    else
      @errors = @role.valid? ? [] : {'email' => 'A user with this email address already exists'}
      render :action=>:new_user
    end
  end
  
  def show_change_password
    @user = current_user
  end

  def change_password
    if current_user.update_password(params[:user])
      sign_in(current_user, :bypass => true)
      flash[:notice] = "Password changed"
      redirect_to '/'
    else
      flash.now[:alert] = "Error updating password"
      render :action=>:show_change_password
    end
  end

  def show_init
    #create initial user
    if User.count > 0
      return redirect_to :action=>:new
    end
    @user = User.new
  end


  def init
    if User.count > 0
      return redirect_to :action=>:new
    end
    @user = User.new params[:user]
    @user.current_provider_id = 1
    @user.save!
    @role = Role.new ({:user_id=>@user.id, :provider_id=>1, :level=>100})
    @role.save

    flash[:notice] = "OK, now sign in"
    redirect_to :action=>:new
  end

  def change_provider
    provider = Provider.find(params[:provider_id])
    if can? :read, provider
      current_user.current_provider_id = provider.id
      current_user.save!
    end
    redirect_to params[:come_from]
  end

  def check_session
    last_request_at = session['warden.user.user.session']['last_request_at']
    timeout_time = last_request_at + Rails.configuration.devise.timeout_in
    timeout_in = (timeout_time - Time.current).to_i
    render :json => {
      'last_request_at' => last_request_at,
      'timeout_in' => timeout_in,
    }
  end

  def touch_session
    render :text => 'OK'
  end

end
