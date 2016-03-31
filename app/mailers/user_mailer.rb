class UserMailer < ActionMailer::Base
  default from: 'noreply@twilight-glade.herokuapp.com'
  after_action :set_subject

  def welcome(user)
    @user = user
    @greeting = greeting_for(user)
    mail.to = @user.email
  end

  def email_confirmation(user)
    @user = user
    @greeting = greeting_for(user)
    @url = email_confirmation_link_for(user)
    mail.to = @user.email
  end

  def email_change_confirmation(user)
    @user = user
    @greeting = greeting_for(user)
    @url = email_confirmation_link_for(user)
    mail.to = @user.email
  end

  def email_changed_notice(user)      
    @user = user
    @greeting = greeting_for(user)
    mail.to = @user.old_email
  end

  def password_reset(user)
    @user = user
    @greeting = greeting_for(user)
    @url = password_reset_link_for(user)
    mail.to = @user.email
  end

  private
    def set_subject      
      mail.subject = t("m.user_mailer.#{action_name}.subject")
    end
    
    def greeting_for(user)
      t('m.user_mailer.greeting', first_name: user.first_name)
    end

    def email_confirmation_link_for(user)
      edit_email_confirmation_url(hashed_email: User.digest(user.email),
        token: user.email_confirmation_token)
    end

    def password_reset_link_for(user)
      edit_password_url(hashed_email: User.digest(user.email),
        token: user.password_reset_token)
    end
end