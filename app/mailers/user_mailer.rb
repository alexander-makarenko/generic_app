class UserMailer < ActionMailer::Base
  default from: 'noreply@example.com'

  def email_confirmation(user)
    @greeting = t('m.user_mailer.greeting', first_name: user.first_name)
    @url = edit_email_confirmation_url(      
      hashed_email: User.digest(user.email),
      token: user.email_confirmation_token
    )
    mail(
      to: user.email,
      subject: t('m.user_mailer.email_confirmation.subject')
    )
  end

  def password_reset(user)
    @greeting = t('m.user_mailer.greeting', first_name: user.first_name)
    @url = edit_password_url(      
      hashed_email: User.digest(user.email),
      token: user.password_reset_token
    )
    mail(
      to: user.email,
      subject: t('m.user_mailer.password_reset.subject')
    )
  end
end