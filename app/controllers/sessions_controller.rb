class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      if user.activated?
        sign_in(user, params[:keep_signed_in])
        flash[:success] = 'You have signed in.'
      else
        # REFACTOR THIS MESSAGE INTO A HERE DOCUMENT
        message  = "Account not activated. Please check your email for the "
        message += "activation link. If you haven't received it, be sure to look "
        message += "into your spam folder, or request another activation email "
        message += "#{view_context.link_to('here', new_account_activation_path)}."
        flash[:alert] = message
      end
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
