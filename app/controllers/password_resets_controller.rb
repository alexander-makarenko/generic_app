class PasswordResetsController < ApplicationController
  before_action { authorize PasswordReset.new }

  def new
    @password_reset = PasswordReset.new
  end

  def create
    @password_reset = PasswordReset.new(params[:password_reset])
    @password_reset.skip_password_validation = true

    if @password_reset.valid?
      user = User.find_by(email: @password_reset.email.downcase)
      user.send_link(:password_reset) if user
      redirect_to root_path, notice: t('c.password_resets.create.flash.notice')
    else
      render :new
    end
  end

  def edit
    @password_reset = PasswordReset.new
    user = User.find_by(email: decode(params[:e]))

    if user && user.authenticated(:password_reset_token, params[:token])
      if user.link_expired?(:password_reset)
        redirect_to root_path, error: t(
          'c.password_resets.edit.flash.error.1',
          link: view_context.link_to(
            t('c.password_resets.edit.flash.link'),
            new_password_reset_path))
      else
        render :edit
      end
    else
      redirect_to root_path, error: t('c.password_resets.edit.flash.error.2')
    end
  end

  def update
    @password_reset = PasswordReset.new(params[:password_reset])
    @password_reset.email = decode(params[:e])
    user = User.find_by(email: @password_reset.email)

    if user && user.authenticated(:password_reset_token, params[:token])
      if @password_reset.valid?
        user.attributes = {
          password: @password_reset.password,
          password_reset_email_sent_at: nil }
        user.save(validate: false)
        redirect_to signin_path,
          success: t('c.password_resets.update.flash.success')
      else
        render :edit
      end
    else
      redirect_to root_path
    end
  end
end