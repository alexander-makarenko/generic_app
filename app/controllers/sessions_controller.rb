class SessionsController < ApplicationController
  before_action { authorize :session }

  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticated(:password, params[:password])
      if user.activated?
        sign_in(user, params[:keep_signed_in])
        flash[:success] = t('c.sessions.create.flash.success')
      else
        flash[:alert] = t('c.sessions.create.flash.alert',
          link: view_context.link_to(
            t('c.sessions.create.flash.link'),
            new_account_activation_path))
      end
      redirect_to root_path
    else
      flash.now[:error] = t('c.sessions.create.flash.error')
      render :new
    end
  end

  def destroy
    sign_out
    redirect_to root_path, notice: t('c.sessions.destroy.flash.notice')
  end
end