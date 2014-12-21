class AccountActivationPolicy < ApplicationPolicy
  attr_reader :current_user, :account_activation

  def initialize(current_user, account_activation)
    @current_user = current_user
    @account_activation = account_activation
  end

  def create?
    !signed_in?
  end

  def edit?
    !signed_in?
  end
end