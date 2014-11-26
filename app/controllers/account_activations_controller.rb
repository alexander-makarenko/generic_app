class AccountActivationsController < ApplicationController
  def new
  end

  def edit
    begin
      decoded_email = Base64.urlsafe_decode64(URI.decode(params[:e])) if params[:e]
    rescue ArgumentError
      raise ActionController::BadRequest
    end

    user = User.find_by(email: decoded_email)

    if user && user.activation_digest == User.digest(params[:token])
      if !user.activated_in_time?
        flash[:error] = "Activation link has expired. To request another activation email, click #{view_context.link_to('here', new_account_activation_path)}."
        redirect_to root_path
      else
        activate(user)
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

  private
    def activate(user)
      user.attributes = { activated: true, activated_at: Time.zone.now }
      user.save(validate: false)
    end
end