class AccountActivationsController < ApplicationController
  before_action { authorize :account_activation }  
  rescue_from User::AlreadyActivated, with: :user_already_activated  
  
  def new
    raise User::AlreadyActivated if current_user.activated?
  end

  def create
    user = current_user
    raise User::AlreadyActivated if user.activated?
    if user.authenticated(:password, params[:password])
      user.assign_and_validate_attributes(email: params[:email])
      if user.errors.empty?
        user.save(validate: false)
        user.send_email(:activation)
        redirect_to root_path,
          info: t('c.account_activations.create.flash.info')
      else        
        render :new
      end      
    else
      flash.now[:danger] = t('c.account_activations.create.flash.danger')
      render :new
    end
  end

  def edit
    user = User.find_by(activation_digest: User.digest(params[:token]))  
    if user && User.digest(user.email) == params[:hashed_email]
      raise User::AlreadyActivated if user.activated?
      unless user.link_expired?(:activation)
        user.attributes = {
          activated: true,
          activated_at: Time.zone.now,
          activation_sent_at: nil
        }
        user.save(validate: false)
        redirect_to root_path,
          success: t('c.account_activations.edit.flash.success')
      else        
        redirect_to root_path,
          danger: t('c.account_activations.edit.flash.danger.expired',
            link: view_context.link_to(
              t('c.account_activations.edit.flash.link'),
              new_account_activation_path))
      end
    else
      redirect_to root_path,
        danger: t('c.account_activations.edit.flash.danger.invalid',
          link: view_context.link_to(
            t('c.account_activations.edit.flash.link'),
            new_account_activation_path))
    end
  end

  private
    def user_already_activated
      redirect_to root_path, danger: t('c.account_activations.already_activated')
    end  
end