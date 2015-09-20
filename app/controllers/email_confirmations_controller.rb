class EmailConfirmationsController < ApplicationController
  I18N_SCOPE = "c.#{controller_name}"

  before_action { authorize :email_confirmation }

  def create
    current_user.send_email(:email_confirmation)
    flash[:success] = t('email_sent', scope: I18N_SCOPE, email: current_user.email)
    redirect_to account_path
  end

  def edit
    user = User.find_by(email_confirmation_digest: User.digest(params[:token]))

    link = view_context.link_to(t('get_new_link', scope: I18N_SCOPE),
      email_confirmations_path, method: :post, class: 'alert-link')
    
    if user.try(:authenticate_by, hashed_email: params[:hashed_email])
      if user.link_expired?(:email_confirmation)
        flash[:danger] = t('link_expired', scope: I18N_SCOPE, get_new_link: link)
      else
        key = user.email_change_pending? ? 'email_changed' : 'email_confirmed'
        flash[:success] = t(key, scope: I18N_SCOPE, email: user.email)
        user.confirm_email
        user.save(validate: false)
        (redirect_to(account_path) if signed_in?) and return
      end
    else
      flash[:danger] = t('link_invalid', scope: I18N_SCOPE, get_new_link: link)
    end
    redirect_to(root_path)
  end

  private

    def user_not_authorized
      flash[:danger] = not_authorized_message
      redirect_to(action_name == 'create' ? signin_path : root_path)
    end
end