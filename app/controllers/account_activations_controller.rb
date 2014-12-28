class AccountActivationsController < ApplicationController
  before_action { authorize :account_activation }

  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)

    if user && user.authenticated(:password, params[:password])
      user.send_link(:activation)
      redirect_to root_path, notice: t('c.account_activations.create.flash.notice')
    else
      flash.now[:error] = t('c.account_activations.create.flash.error')
      render :new
    end
  end

  def edit
    user = User.find_by(email: decode(params[:e]))

    if user && user.authenticated(:activation_token, params[:token])
      if user.link_expired?(:activation)
        redirect_to root_path, error: t(
          'c.account_activations.edit.flash.error.1',
          link: view_context.link_to(
            t('c.account_activations.edit.flash.link'),
            new_account_activation_path))
      else
        user.attributes = {
          activated: true,
          activated_at: Time.zone.now,
          activation_email_sent_at: nil }
        user.save(validate: false)
        redirect_to signin_path, success: t(
          'c.account_activations.edit.flash.success')
      end
    else
      redirect_to root_path, error: t(
        'c.account_activations.edit.flash.error.2',
        link: view_context.link_to(
          t('c.account_activations.edit.flash.link'),
          new_account_activation_path))
    end
  end
end