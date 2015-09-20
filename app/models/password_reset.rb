class PasswordReset
  include ActiveModel::Model

  attr_reader :email
  attr_accessor :user

  validates :email, presence: true, length: { maximum: 50 }
  validates :email, format: { with: EMAIL_REGEX }, if: -> { email.present? }
  validate  :verify_email_belongs_to_existing_user, unless: -> { errors.include?(:email) }

  def email=(value)
    @email = value.downcase
  end

  def verify_email_belongs_to_existing_user    
    errors.add(:email, :nonexistent) unless self.user = User.find_by(email: email)
  end
end