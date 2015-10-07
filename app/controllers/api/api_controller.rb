class API::ApiController < ActionController::Base
  skip_before_action :authenticate_user!, :verify_authenticity_token
  before_filter :authenticate_user_from_token!, :cors_set_access_control_headers

  # necessary in all controllers that will respond with JSON
  respond_to :json 

  private

  def error(status, message = 'Something went wrong')
    response = {
      error: message
    }

    render json: response.to_json, status: status
  end

  def authenticate_user_from_token!
    token = request.headers['X-RIDEPILOT-TOKEN']

    if token.blank? 
      return error(:forbidden, TranslationEngine.translate_text(:ridepilot_token_required))
    else
      @user = BookingUser.find_by_token(token).try(:user)
      return error(:unauthorized, TranslationEngine.translate_text(:invalid_ridepilot_token)) if !@user
    end
  end

  def cors_set_access_control_headers

    origin = request.env['HTTP_ORIGIN']
    # if the incoming origin is registered, then allow requests from it
    if @user.try(:url) == origin
      headers['Access-Control-Allow-Origin'] = origin
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
      headers['Access-Control-Max-Age'] = "1728000"
    end
  end

end