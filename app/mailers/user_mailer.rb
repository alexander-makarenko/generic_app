class UserMailer < ActionMailer::Base
  default from: 'noreply@example.com'

  def activation(user)
    @activation_link = edit_account_activation_url(
      token: user.activation_token,
      e: encode(user.email))

    mail(
      to: user.email,
      subject: t('m.user_mailer.activation.subject'))
  end

  def password_reset(user)
    @password_reset_link = edit_password_url(
      token: user.password_reset_token,
      e: encode(user.email))

    mail(
      to: user.email,
      subject: t('m.user_mailer.password_reset.subject'))
  end

  private
    def encode(value)
      Base64.urlsafe_encode64(value.to_s)
    end
end