class ApplicationController < ActionController::Base
  include SessionsHelper
  include Pundit

  add_flash_types :success, :info, :danger, :warning  

  before_action :set_locale

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  private  
    def user_not_authorized(exception)
      unless flash[:danger]
        policy_name = exception.policy.class.to_s.underscore
        flash[:danger] = t "#{policy_name}.#{exception.query}", scope: 'p', default: :default
      end
      redirect_to(request.referrer || localized_root_path)
    end
end