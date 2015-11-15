class AvatarsController < ApplicationController
  before_action { authorize :avatar }

  def create
    @user = current_user
    @user.avatar = params['file-select']
    @user.skip_password_validation = true
    @message = t('c.avatars.changed')

    respond_to do |format|
      format.js
      format.html do
        if @user.save
          redirect_to account_path, success: @message
        else
          @user.reload
          render 'users/show'
        end
      end
    end
  end

  def destroy
    @user = current_user
    @user.avatar = nil
    @user.save(validate: false)
    @message = t('c.avatars.deleted')

    respond_to do |format|
      format.js
      format.html { redirect_to account_path, success: @message }
    end
  end
end