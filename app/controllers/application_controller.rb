class ApplicationController < ActionController::Base
  include SessionsHelper
  include Pundit

  add_flash_types :success, :error
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def decode(encoded_param)
    begin
      Base64.urlsafe_decode64(URI.decode(encoded_param)) if encoded_param
    rescue ArgumentError
      raise ActionController::BadRequest
    end
  end

  private
  
    def user_not_authorized
      flash[:error] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end
end