class EmailConfirmationPolicy < ApplicationPolicy
  attr_reader :current_user, :email_confirmation

  def initialize(current_user, email_confirmation)
    @current_user = current_user
    @email_confirmation = email_confirmation
  end

  def create?
    signed_in? && !email_confirmed?
  end

  def update?
    !(signed_in? && email_confirmed?)
  end

  private
    def email_confirmed?
      current_user.email_confirmed?
    end
end