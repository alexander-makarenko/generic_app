class PasswordResetsController < ApplicationController
  I18N_SCOPE = "c.#{controller_name}"

  before_action { authorize :password_reset }

  def new
    @password_reset = PasswordReset.new
  end

  def create
    @password_reset = PasswordReset.new(params_for_create)
    if @password_reset.valid?
      @password_reset.user.send_email(:password_reset)
      flash[:info] = t('instructions_sent', scope: I18N_SCOPE, email: @password_reset.email)
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    session[:hashed_email], session[:token] = params[:hashed_email], params[:token]
    @user = User.find_by(password_reset_digest: User.digest(params[:token]))

    link = view_context.link_to(t('get_new_link', scope: I18N_SCOPE),
      new_password_reset_path, class: 'alert-link')

    if @user.try(:authenticate_by, hashed_email: params[:hashed_email])
      if @user.link_expired?(:password_reset)
        flash[:danger] = t('link_expired', scope: I18N_SCOPE, get_new_link: link)
      else
        render :edit and return
      end
    else
      flash[:danger] = t('link_invalid', scope: I18N_SCOPE, get_new_link: link)
    end
    redirect_to root_path
  end

  def update
    @user = User.find_by(password_reset_digest: User.digest(session[:token]))
    if @user.try(:authenticate_by, hashed_email: session[:hashed_email])
      @user.attributes = params_for_update
      if @user.valid?
        @user.password_reset_sent_at = nil
        @user.save
        session.delete(:token) && session.delete(:hashed_email)
        sign_in @user
        redirect_to account_path, success: t('password_changed', scope: I18N_SCOPE)
      else
        render :edit
      end
    else
      redirect_to root_path
    end
  end

  private

    def params_for_create
      params.require(:password_reset).permit(:email)
    end

    def params_for_update
      params.require(:user).permit(:password, :password_confirmation)
    end
end