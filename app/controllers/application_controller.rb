class ApplicationController < ActionController::Base
  include ActionView::Helpers::DateHelper
  include SessionsHelper
  include Pundit

  add_flash_types :success, :info, :warning, :danger

  before_action :set_locale

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def set_locale
    I18n.locale = case      
    when params[:locale]
      params[:locale]
    when current_user
      current_user.locale
    when I18n.available_locales.map(&:to_s).include?(cookies[:locale])
      cookies[:locale].to_sym
    else
      cookies[:locale] = I18n.default_locale
    end
  end
  
  private
  
    def user_not_authorized(exception)
      unless flash[:danger]
        policy_name = exception.policy.class.to_s.gsub(/policy/i, '').underscore
        flash[:danger] = t "#{policy_name}.#{exception.query}", scope: 'p', default: :default
      end
      redirect_to(request.referrer || root_path)
    end
end