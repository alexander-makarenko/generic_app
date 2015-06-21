class SessionsController < ApplicationController
  before_action { authorize :session }

  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      sign_in(user, params[:keep_signed_in])      
      redirect_to localized_root_path
    else
      flash.now[:danger] = t('c.sessions.create.flash.danger')
      render :new
    end
  end

  def destroy
    sign_out
    redirect_to localized_root_path
  end
end