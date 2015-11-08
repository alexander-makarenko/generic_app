class AvatarsController < ApplicationController
  before_action { authorize :avatar }

  def new
  end

  def create
    @user = current_user
    @user.avatar = params['file-select']    
    @user.skip_password_validation = true
    @success_message = t 'c.avatars.avatar_changed'

    respond_to do |format|
      format.js
      format.html do
        if @user.save
          redirect_to account_path, success: @success_message
        else
          @user.reload
          render 'users/show'
        end
      end
    end    
  end

  def destroy
  end
end