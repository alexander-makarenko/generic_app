class AvatarPolicy < ApplicationPolicy
  attr_reader :current_user, :avatar

  def initialize(current_user, avatar)
    @current_user = current_user
    @avatar = avatar
  end

  def create?
    signed_in?
  end

  def destroy?
    signed_in?
  end
end
