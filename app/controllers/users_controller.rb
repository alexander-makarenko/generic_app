class UsersController < ApplicationController
  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user
    if @user.save
      sign_in @user
      # TO DO: SEND WELCOME EMAIL
      redirect_to localized_root_path, info: t('c.users.create.flash.info', email: @user.email)
    else
      render :new
    end
  end

  def show
    @user = params[:id].nil? ? current_user : User.find(params[:id])
    # redirect_to(localized_root_path) unless @user
    authorize @user
    unless @user.email_confirmed
      link = view_context.link_to(t('c.users.show.flash.link'),
        email_confirmations_path, method: :post)
      sent_at = @user.email_confirmation_sent_at      
      flash.now[:warning] = case
      when !sent_at
        t('c.users.show.flash.warning.1', link: link)
      when sent_at < 5.minutes.ago
        t('c.users.show.flash.warning.3', link: link, time_ago: time_ago_in_words(sent_at))
      else
        t('c.users.show.flash.warning.2', link: link)
      end
    end
  end

  def validate
    @user = User.new
    @user.assign_and_validate_attributes(user_params)
    respond_to do |format|
      format.json { render :validate }
    end
  end
  
  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password,
        :password_confirmation)
    end
end