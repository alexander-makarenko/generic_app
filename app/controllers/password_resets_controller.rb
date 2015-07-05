class PasswordResetsController < ApplicationController
  before_action { authorize :password_reset }

  def new
    @password_reset = PasswordReset.new
  end

  def create
    @password_reset = PasswordReset.new(create_params)
    if @password_reset.valid?
      @password_reset.user.send_email(:password_reset)
      redirect_to localized_root_path, info: t('c.password_resets.create.info')
    else
      render :new
    end
  end

  def edit
    session[:hashed_email], session[:token] = params[:hashed_email], params[:token]

    link = view_context.link_to(t('c.password_resets.edit.link'),
      new_password_reset_path, class: 'alert-link')

    @user = User.find_by(password_reset_digest: User.digest(params[:token]))
    if @user.try(:authenticate_by, digested_email: params[:hashed_email])
      if @user.link_expired?(:password_reset)
        flash[:danger] = t('c.password_resets.edit.expired', link: link)
      else
        render :edit and return
      end
    else
      flash[:danger] = t('c.password_resets.edit.invalid', link: link)
    end
    redirect_to localized_root_path
  end

  def update
    @user = User.find_by(password_reset_digest: User.digest(session[:token]))
    if @user.try(:authenticate_by, digested_email: session[:hashed_email])
      @user.attributes = update_params
      if @user.valid?
        @user.password_reset_sent_at = nil
        @user.save
        session[:token], session[:hashed_email] = nil, nil
        redirect_to signin_path, success: t('c.password_resets.update.success')
      else
        render :edit
      end
    else
      redirect_to localized_root_path
    end
  end

  private

    def create_params
      params.require(:password_reset).permit(:email)
    end

    def update_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end