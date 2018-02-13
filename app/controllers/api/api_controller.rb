class API::ApiController < ActionController::Base
  skip_before_action :authenticate_user!, :verify_authenticity_token, raise: false
  acts_as_token_authentication_handler_for User, fallback: none
end