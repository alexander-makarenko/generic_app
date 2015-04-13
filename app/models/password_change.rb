class PasswordChange
  include ActiveModel::Model

  attr_accessor :user, :current_password, :new_password, :new_password_confirmation

  validate :verify_current_password
  validates :new_password, presence: true, confirmation: true
  validates :new_password, length: { in: 6..30 }, unless: -> { new_password.blank? }

  def verify_current_password
    unless user.authenticated(:password, current_password)
      self.errors.add(:current_password)
    end
  end
end