class PasswordChangePolicy < ApplicationPolicy
  attr_reader :current_user, :password_change

  def initialize(current_user, password_change)
    @current_user = current_user
    @password_change = password_change
  end

  def create?
    signed_in?
  end
end