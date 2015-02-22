class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :do_not_track
  before_filter :authenticate_user!
  before_filter :get_providers
  
  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403.html", :status => 403
  end

  def get_providers
    if !current_user
      return
    end

    ride_connection = Provider.ride_connection
    @provider_map = []
    for role in current_user.roles
      if role.provider == ride_connection 
        @provider_map = Provider.all.collect {|provider| [ provider.name, provider.id ] }
        break
      end
      @provider_map << [role.provider.name, role.provider_id]
    end
    @provider_map.sort!{|a, b| a[0] <=> b[0] }
  end

  def test_exception_notification
    raise 'Testing, 1 2 3.'
  end

  private
  def current_provider_id
    return current_user.current_provider_id
  end

  def current_provider
    return current_user.current_provider
  end

  def do_not_track
    # Devise is supposed to recognize this header, I thought. Unfortunately,
    # I'm having to check it manually.
    if request.headers['devise.skip_trackable']
      request.env['devise.skip_trackable'] = true
    end
  end
end
