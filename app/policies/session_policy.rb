class SessionPolicy < ApplicationPolicy
  attr_reader :current_user, :session

  def initialize(current_user, session)
    @current_user = current_user
    @session = session
  end

  def create?
    !signed_in?
  end

  def destroy?
    signed_in?
  end
end
