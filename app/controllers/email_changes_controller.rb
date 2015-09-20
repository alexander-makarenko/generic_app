class EmailChangesController < ApplicationController
  before_action { authorize :email_change }

  def new
    @email_change = EmailChange.new
  end

  def create
    user = current_user
    @email_change = EmailChange.new(params[:email_change])
    @email_change.user = user
    if @email_change.valid?
      user.change_email_to(@email_change.new_email)      
      user.save(validate: false)
      user.send_email(:email_changed_notice, :email_change_confirmation)
      flash[:success] = t('c.email_changes.create.success', email: @email_change.new_email)
      redirect_to account_path
    else
      render :new
    end
  end

  def destroy
    current_user.cancel_email_change
    current_user.save(validate: false)
    flash[:info] = t('c.email_changes.destroy.info')
    redirect_to account_path
  end
end