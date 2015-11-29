class ApplicationController < ActionController::Base
  include ActionView::Helpers::DateHelper
  include SessionsHelper
  include Pundit

  add_flash_types :success, :info, :warning, :danger

  before_action :set_locale
  after_action :set_last_seen_at

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def set_last_seen_at
    if signed_in? && (session[:last_seen_at].nil? || session[:last_seen_at] < 3.minutes.ago)
      current_time = Time.zone.now
      current_user.update_attribute(:last_seen_at, current_time)
      session[:last_seen_at] = current_time
    end
  end

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
  
    def not_authorized_message
      t("#{controller_name.sub(/s\z/, '')}.#{action_name}?", scope: 'p', default: :default)
    end

    def user_not_authorized
      flash[:danger] = not_authorized_message
      store_location
      redirect_to signin_path
    end
end