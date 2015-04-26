class SessionsController < ApplicationController
  before_action { authorize :session }

  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticated(:password, params[:password])
      sign_in(user, params[:keep_signed_in])      
      redirect_to localized_root_path(locale: I18n.locale)
    else
      flash.now[:danger] = t('c.sessions.create.flash.danger')
      render :new
    end
  end

  def destroy
    sign_out
    redirect_to localized_root_path(locale: I18n.locale)
  end
end