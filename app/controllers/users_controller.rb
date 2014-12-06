class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:notice] = 'An activation email has been sent to your email address. Click the link in the message to activate your account.'
      @user.send_activation_link
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.assign_attributes(user_params)

    if @user.valid?
      if User.find(params[:id]).authenticated(:password, @user.password)
        @user.save
        flash[:success] = 'Your profile was successfully updated.'
        redirect_to root_path
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