class UserPolicy < ApplicationPolicy
  attr_reader :current_user, :user

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end

  def create?
    !signed_in?
  end

  def show?
    signed_in?
  end

  def validate?
    create?
  end

  def index?
    admin?
  end

  private

    def admin?
      current_user.try(:admin?)
    end
end