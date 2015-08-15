class LocaleChangePolicy < ApplicationPolicy
  attr_reader :current_user, :locale_change

  def initialize(current_user, locale_change)
    @current_user = current_user
    @locale_change = locale_change
  end

  def create?
    true
  end
end