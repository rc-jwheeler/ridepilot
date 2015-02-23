class UsersController < ApplicationController
  require 'new_user_mailer'

  def new_user
    if User.count == 0
      return redirect_to :show_init
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
          @user = User.new(create_user_params)
          @user.password = User.generate_password
          raw, enc = Devise.token_generator.generate(User, :reset_password_token)
          @user.reset_password_token = enc
          @user.reset_password_sent_at = Time.now.utc
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
      user_errors = @user.valid? ? {} : @user.errors.messages
      role_errors = @role.valid? ? {} : @role.errors.messages
      @errors = user_errors.merge(role_errors)
      render :action => :new_user
    end
  end
  
  def show_change_password
    @user = current_user
  end

  def change_password
    if current_user.update_password(change_password_params)
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
      return redirect_to new_user_session_path
    end
    @user = User.new
  end

  def init
    if User.count > 0
      return redirect_to new_user_session_path
    end
    @user = User.new(init_user_params)
    @user.current_provider = Provider.ride_connection
    @user.save!
    @role = Role.new ({:user_id=>@user.id, :provider_id=>1, :level=>100})
    @role.save

    flash[:notice] = "OK, now sign in"
    redirect_to new_user_session_path
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
    timeout_time = last_request_at + Rails.configuration.devise.timeout_in.to_i
    timeout_in = timeout_time - Time.current.to_i
    render :json => {
      'last_request_at' => last_request_at,
      'timeout_in' => timeout_in,
    }
  end

  def touch_session
    render :text => 'OK'
  end

  private
  
  def init_user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
  
  def create_user_params
    params.require(:user).permit(:email)
  end
  
  def change_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
