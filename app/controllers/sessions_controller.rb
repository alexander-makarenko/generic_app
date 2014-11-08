class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      sign_in(user, params[:keep_signed_in])
      flash[:success] = 'You have been signed in.'
      redirect_to root_path
    else
      flash.now[:error] = 'Invalid email or password.'
      render :new
    end
  end

  def destroy
    sign_out
    flash[:notice] = 'You have signed out.'
    redirect_to root_path
  end
end
