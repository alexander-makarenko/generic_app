class UserMailer < ActionMailer::Base
  default from: 'noreply@example.com'
  after_action :set_defaults

  def email_change_confirmation(user)
    @user = user
    @url = email_confirmation_link_for(user)
    mail.to = @user.email
  end

  def email_changed_notice(user)      
    @user = user
    mail.to = @user.old_email
  end

  def email_confirmation(user)
    @user = user
    @url = email_confirmation_link_for(user)
    mail.to = @user.email
  end

  def password_reset(user)
    @user = user
    @url = password_reset_link_for(user)
    mail.to = @user.email
  end

  def welcome(user)
    @user = user
    mail.to = @user.email
  end

  private

    def set_defaults
      mailer = self.class.to_s.underscore
      @greeting = t("m.#{mailer}.greeting", first_name: @user.first_name)
      mail.subject = t("m.#{mailer}.#{action_name}.subject")
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