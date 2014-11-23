class AccountActivationsController < ApplicationController
  def new
  end

  def edit
    user = User.find_by(email: params[:email].downcase)

    if user && (user.activation_digest == User.digest(params[:token]))
      if user.activation_email_sent_at < 2.days.ago
        flash[:error] = "Activation link has expired. To request another activation email, click #{view_context.link_to('here', new_account_activation_path)}."
        redirect_to root_path
      else
        user.attributes = { activated: true, activated_at: Time.zone.now }
        user.save(validate: false)
        flash[:success] = 'Thank you for confirming your email address. You can now sign in.'
        redirect_to signin_path
      end
    else
      flash[:error] = "Activation link is invalid. To request another activation email, click #{view_context.link_to('here', new_account_activation_path)}."
      redirect_to root_path
    end
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      user.send_activation_link
      flash[:notice] = 'An activation email has been sent to your email address. Click the link in the message to activate your account.'
      redirect_to root_path
    else
      flash.now[:error] = 'Invalid email or password.'
      render :new
    end
  end  
end
