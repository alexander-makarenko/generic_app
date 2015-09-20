class PasswordChange
  include ActiveModel::Model

  attr_accessor :user, :current_password, :new_password, :new_password_confirmation

  validate :current_password_is_correct
  validates :new_password, presence: true, confirmation: true
  validates :new_password, length: { in: 6..30 }, unless: -> { new_password.blank? }

  def current_password_is_correct
    errors.add(:current_password) unless user.authenticate(current_password)
  end
end