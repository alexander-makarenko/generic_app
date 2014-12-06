class PasswordReset
  include ActiveModel::Model

  EMAIL_REGEX = /\A[\w+-]+(\.[\w-]+)*@[a-z\d]+(\.[a-z\d-]+)*(\.[a-z]{2,4})\z/i

  attr_accessor :email, :password, :password_confirmation, :skip_password_validation
  alias_method  :skip_password_validation?, :skip_password_validation

  validates :email, presence: true, length: { maximum: 50 }
  validates :email, format: { with: EMAIL_REGEX }, unless: -> { email.blank? }
  
  validates :password, presence: true, unless: :skip_password_validation?
  validates :password, confirmation: true
  validates :password, length: { in: 6..30 }, unless: -> { password.blank? }
end