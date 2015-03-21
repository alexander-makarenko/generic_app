class PasswordResetPolicy < ApplicationPolicy
  attr_reader :current_user, :password_reset

  def initialize(current_user, password_reset)
    @current_user = current_user
    @password_reset = password_reset
  end

  def create?
    true
  end

  def update?
    true
  end
end