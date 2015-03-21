class UserMailer < ActionMailer::Base
  default from: 'noreply@example.com'

  def activation(user)
    @greeting = t('m.user_mailer.greeting', first_name: user.first_name)
    @activation_link = edit_account_activation_url(
      hashed_email: User.digest(user.email),
      token: user.activation_token)

    mail(
      to: user.email,
      subject: t('m.user_mailer.activation.subject'))
  end

  def password_reset(user)
    @greeting = t('m.user_mailer.greeting', first_name: user.first_name)
    @password_reset_link = edit_password_url(
      hashed_email: User.digest(user.email),
      token: user.password_reset_token)

    mail(
      to: user.email,
      subject: t('m.user_mailer.password_reset.subject'))
  end
end