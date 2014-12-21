class ApplicationPolicy
  attr_reader :user, :record

  def initialize(current_user, record)
    @current_user = current_user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def new?
    create?
  end

  def create?
    false
  end

  def edit?
    update?
  end

  def update?
    false
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  private

    def signed_in?
      !current_user.nil?
    end

    def current_user?(user)
      user == current_user
    end

    def requested?(link_type)
      !current_user.send("#{link_type}_email_sent_at").nil?
    end

    def link_expired?(link_type)
      current_user.link_expired?(link_type)
    end
end