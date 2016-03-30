class SessionsController < ApplicationController
  before_action { authorize :session }

  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    respond_to do |format|
      if user.try(:authenticate, params[:password])
        sign_in(user, params[:keep_signed_in])        
        format.html { redirect_back_or root_path }
      else
        flash.now[:danger] = t('c.sessions.invalid_credentials')
        format.html { render :new }
      end
      format.js
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  private

    def user_not_authorized
      redirect_to root_path
    end
end