class AccountActivationsController < ApplicationController
  before_action { authorize :account_activation }

  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)

    if user && user.authenticated(:password, params[:password])
      user.send_link(:activation)
      redirect_to root_path, notice: 'An activation email has been sent to your email address. Click the link in the message to activate your account.'
    else
      flash.now[:error] = 'Invalid email or password.'
      render :new
    end
  end

  def edit
    user = User.find_by(email: decode(params[:e]))

    if user && user.authenticated(:activation_token, params[:token])
      if user.link_expired?(:activation)
        redirect_to root_path, error: "The link has expired. To request another activation email, click #{view_context.link_to('here', new_account_activation_path)}."
      else
        user.attributes = {
          activated: true,
          activated_at: Time.zone.now,
          activation_email_sent_at: nil }
        user.save(validate: false)
        redirect_to signin_path, success: 'Thank you for confirming your email address. You can now sign in.'
      end
    else
      redirect_to root_path, error: "The link is invalid. To request another activation email, click #{view_context.link_to('here', new_account_activation_path)}."
    end
  end
end