class EmailChange
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  before_validation :downcase_new_email_and_confirmation

  attr_accessor :user, :new_email, :new_email_confirmation, :current_password

  validates :new_email, presence: true, length: { maximum: 50 }, confirmation: true  
  validates :new_email, format: { with: EMAIL_REGEX }, if: -> { new_email.present? }  
  validate  :current_password_is_correct, :email_is_available

  private

    def current_password_is_correct
      errors.add(:current_password) unless user.authenticate(current_password)
    end

    def email_is_available
      if User.exists?(email: new_email)
        errors.add(:new_email, (new_email == user.email ? :unchanged : :taken))
      end
    end
    
    def downcase_new_email_and_confirmation
      new_email.try(:downcase!)
      new_email_confirmation.try(:downcase!)
    end
end