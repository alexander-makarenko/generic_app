class NameChangePolicy < ApplicationPolicy
  attr_reader :current_user, :name_change

  def initialize(current_user, password_change)
    @current_user = current_user
    @name_change = name_change
  end

  def create?
    signed_in?
  end
end