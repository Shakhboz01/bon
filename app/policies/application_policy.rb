class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, 'You must be logged in' unless user

    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def manage?
    false
  end

  def destroy?
    false
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      raise Pundit::NotAuthorizedError, 'must be logged in' unless user

      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  def user_is_admin?
    user.админ?
  end

  def user_is_manager?
    %w[админ менеджер].include?(user.role)
  end

  def everyone_is_allowed?
    %w[админ менеджер].include?(user.role)
  end

  def user_is_accaontant?
    %w[админ менеджер].include?(user.role)
  end

  def user_is_skladchik?
    %w[админ менеджер складчик].include?(user.role)
  end

  def user_is_agent?
    %w[админ менеджер агент].include?(user.role)
  end
end
