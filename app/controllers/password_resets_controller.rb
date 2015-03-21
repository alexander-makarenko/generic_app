class PasswordResetsController < ApplicationController
  before_action { authorize :password_reset }

  def new
    @mock_user = User.new
  end

  def create
    @mock_user = User.new
    @mock_user.assign_and_validate_attributes(create_params)

    if @mock_user.errors.added?(:email, :taken)
      User.find_by_email(@mock_user.email.downcase).send_email(:password_reset)
      redirect_to root_path, notice: t('c.password_resets.create.flash.notice')
    else
      flash.now[:error] = t('c.password_resets.create.flash.error') if @mock_user.errors.empty?
      render :new
    end
  end

  def edit
    if params[:token] && params[:hashed_email]
      session[:token], session[:hashed_email] = params[:token], params[:hashed_email]      
    end

    user = User.find_by(password_reset_digest: User.digest(params[:token]))    
    if user && User.digest(user.email) == params[:hashed_email]
      unless user.link_expired?(:password_reset)
        @mock_user = User.new
        render :edit
      else
        redirect_to root_path,
          error: t('c.password_resets.edit.flash.error.expired',
            link: view_context.link_to(t('c.password_resets.edit.flash.link'),
              new_password_reset_path))
      end
    else
      redirect_to root_path,
        error: t('c.password_resets.edit.flash.error.invalid',
          link: view_context.link_to(t('c.password_resets.edit.flash.link'),
            new_password_reset_path))
    end
  end

  def update
    user = User.find_by(password_reset_digest: User.digest(session[:token]))
    if user && User.digest(user.email) == session[:hashed_email]
      @mock_user = User.new      
      @mock_user.assign_and_validate_attributes(update_params.slice(
        :password, :password_confirmation))
      if @mock_user.errors.empty?
        user.attributes = {
          password: @mock_user.password,
          password_reset_sent_at: nil }
        user.save(validate: false)
        session[:token], session[:hashed_email] = nil, nil
        redirect_to signin_path,
          success: t('c.password_resets.update.flash.success')
      else
        render :edit
      end
    else
      redirect_to root_path
    end
  end

  private
    def create_params
      params.require(:password_reset).permit(:email)
    end

    def update_params
      params.require(:password_reset).permit(:password, :password_confirmation)
    end
end