class PasswordChangesController < ApplicationController
  before_action { authorize :password_change }

  def new
    @password_change = PasswordChange.new
  end

  def create
    @password_change = PasswordChange.new(params[:password_change])
    @password_change.user = current_user
    
    if @password_change.valid?
      current_user.update_attribute(:password, @password_change.new_password)
      flash[:success] = t('password_changed', scope: "c.#{controller_name}")
      redirect_to account_path
    else
      render :new
    end
  end
end