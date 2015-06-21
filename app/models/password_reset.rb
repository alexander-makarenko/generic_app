class PasswordReset
  include ActiveModel::Model

  attr_reader :email
  attr_accessor :user

  validates :email, presence: true, length: { maximum: 50 }
  validates :email, format: { with: EMAIL_REGEX }, if: -> { email.present? }
  validate :user_with_given_email_exists, unless: -> { errors.include?(:email) }

  def email=(value)
    @email = value.downcase
  end

  def user_with_given_email_exists
    user = User.find_by(email: email)
    if user
      self.user = user
    else
      errors.add(:email, :nonexistent)
      self.user = nil
    end
  end
end