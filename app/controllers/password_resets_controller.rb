class PasswordResetsController < ApplicationController
  def new
    @password_reset = PasswordReset.new
  end

  def create
    @password_reset = PasswordReset.new(params[:password_reset])
    @password_reset.skip_password_validation = true

    if @password_reset.valid?
      user = User.find_by(email: @password_reset.email.downcase)
      user && user.send_password_reset_link
      flash[:notice] = 'Password reset instructions sent.'
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @password_reset = PasswordReset.new
    user = User.find_by(email: decode(params[:e]))

    if user && user.authenticated(:password_reset_token, params[:token])
      if user.link_expired?(:password_reset)
        flash[:error] = "The link has expired. If you still want to reset your password, click #{view_context.link_to('here', new_password_reset_path)}."
        redirect_to root_path
      else
        render :edit
      end
    else
      flash[:error] = 'The link is invalid.'
      redirect_to root_path
    end
  end

  def update
    @password_reset = PasswordReset.new(params[:password_reset])
    @password_reset.email = decode(params[:e])
    user = User.find_by(email: @password_reset.email)

    if user && user.authenticated(:password_reset_token, params[:token])
      if @password_reset.valid?
        user.update_attribute(:password, @password_reset.password)
        flash[:success] = 'Password successfully updated. You can now sign in:'
        redirect_to signin_path
      else
        render :edit
      end
    else
      redirect_to root_path
    end
  end

  private
    def decode(encoded_param)
      begin
        encoded_param && Base64.urlsafe_decode64(URI.decode(encoded_param))
      rescue ArgumentError
        raise ActionController::BadRequest
      end
    end
end