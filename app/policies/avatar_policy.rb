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
    signed_in? && has_avatar?
  end

  private

    def has_avatar?
      current_user.avatar.file?
    end
end
