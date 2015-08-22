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
      @user.send_email(:welcome)
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @user = current_user || User.new
    authorize @user
    unless @user.email_confirmed
      flash.now[:warning] = email_confirmation_message_for(@user)
    end
  end

  def validate
    @user = User.new
    authorize @user
    @user.attributes_valid?(user_params)
    respond_to do |format|
      format.json { render :validate }
    end
  end
  
  private
  
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password,
        :password_confirmation)
    end

    def email_confirmation_message_for(user)
      link = view_context.link_to(t('c.users.show.link'),
        email_confirmations_path, method: :post, class: 'alert-link')
      sent_at = user.email_confirmation_sent_at
      case
      when !sent_at
        t('c.users.show.email_not_confirmed', link: link)
      when sent_at > 3.minutes.ago
        t('c.users.show.confirmation_just_sent')
      else
        t('c.users.show.confirmation_sent_mins_ago',
          time_ago: time_ago_in_words(sent_at), link: link)
      end
    end

    def user_not_authorized
      action_name == 'show' ? super : redirect_to(root_path)
    end
end