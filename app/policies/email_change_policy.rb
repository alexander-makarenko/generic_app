class EmailChangePolicy < ApplicationPolicy
  attr_reader :current_user, :email_change

  def initialize(current_user, email_change)
    @current_user = current_user
    @email_change = email_change
  end

  def create?
    signed_in?
  end

  def destroy?
    email_change_pending?
  end

  private

    def email_change_pending?
      current_user.try(:email_change_pending?)
    end
end