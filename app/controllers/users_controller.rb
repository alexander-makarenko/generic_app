class UsersController < ApplicationController
  def validate    
    @user = User.new
    @user.assign_and_validate_attributes(user_params)

    respond_to do |format|
      format.json { render :validate }
    end
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      @user.send_email(:activation)
      sign_in(@user)
      redirect_to localized_root_path(locale: I18n.locale),
        info: t('c.users.create.flash.info', email: @user.email)
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

    if User.find(params[:id]).authenticated(:password, @user.password)
      if @user.valid?
        @user.save
        redirect_to localized_root_path(locale: I18n.locale),
          success: t('c.users.update.flash.success')
      else
        render :edit
      end
    else
      @user.errors.add(:password)      
      render :edit
    end
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password,
        :password_confirmation)
    end
end