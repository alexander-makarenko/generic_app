class UsersController < ApplicationController
  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      @user.send_link(:activation)
      redirect_to root_path, notice: 'An activation email has been sent to your email address. Click the link in the message to activate your account.'
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user

    @user.assign_attributes(user_params)

    if @user.valid?
      if User.find(params[:id]).authenticated(:password, @user.password)
        @user.save
        redirect_to root_path, success: 'Your profile was successfully updated.'
      else
        flash.now[:error] = 'Wrong password.'
        render :edit
      end
    else
      render :edit
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end