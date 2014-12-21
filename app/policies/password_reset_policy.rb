class PasswordResetPolicy < ApplicationPolicy
  attr_reader :current_user, :password_reset

  def initialize(current_user, password_reset)
    @current_user = current_user
    @password_reset = password_reset
  end

  def create?
    !signed_in?
  end

  def update?
    !signed_in?    
  end
end