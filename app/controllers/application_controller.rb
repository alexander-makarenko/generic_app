class ApplicationController < ActionController::Base
  include SessionsHelper
  include Pundit

  add_flash_types :success, :error

  before_action :set_locale

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #=======================================================
  # https://github.com/rails/rails/issues/12178 - this bug
  # in rspec caused the tests to fail. remove when fixed
  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end
  #=======================================================

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def decode(encoded_param)
    begin
      Base64.urlsafe_decode64(URI.decode(encoded_param)) if encoded_param
    rescue ArgumentError
      raise ActionController::BadRequest
    end
  end

  private
    def user_not_authorized(exception)
      policy_name = exception.policy.class.to_s.underscore
      flash[:error] = t "#{policy_name}.#{exception.query}", scope: "p", default: :default
      redirect_to(request.referrer || root_path)
    end 
end