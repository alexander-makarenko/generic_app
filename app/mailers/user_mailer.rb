class UserMailer < ActionMailer::Base
  default from: 'noreply@example.com'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def activation(user)
    @activation_token = user.activation_token
    @encoded_email = Base64.urlsafe_encode64(user.email)

    mail(
      to: user.email,
      subject: 'Account activation'
    )
  end

  def password_reset(user)
    @password_reset_token = user.password_reset_token
    @encoded_email = Base64.urlsafe_encode64(user.email)    

    mail(
      to: user.email,
      subject: 'Password reset'
    )
  end
end