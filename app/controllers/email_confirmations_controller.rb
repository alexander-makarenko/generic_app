class EmailConfirmationsController < ApplicationController
  before_action { authorize :email_confirmation }
  
  def create
    current_user.send_email(:email_confirmation)
    redirect_to account_path
  end

  def edit
    link = view_context.link_to(t('c.email_confirmations.edit.flash.link'),
      email_confirmations_path, method: :post)

    user = User.find_by(email_confirmation_digest: User.digest(params[:token]))    
    if user.try(:authenticate_by, digested_email: params[:hashed_email])
      if user.link_expired?(:email_confirmation)
        flash[:danger] = t('c.email_confirmations.edit.flash.danger.expired', link: link)
      else
        user.confirm_email
        user.save(validate: false)
        flash[:success] = t('c.email_confirmations.edit.flash.success')
        (redirect_to(account_path) if signed_in?) and return
      end
    else
      flash[:danger] = t('c.email_confirmations.edit.flash.danger.invalid', link: link)
    end
    redirect_to(localized_root_path)
  end

  private
    def user_not_authorized(exception)
      if exception.query == 'edit?'
        flash[:danger] = t('p.email_confirmation_policy.already_confirmed')
      end
      super
    end
end