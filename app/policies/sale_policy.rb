class SalePolicy < ApplicationPolicy
  def access?
    user_is_manager?
  end

  def manage?
    user_is_accaontant?
  end

  def hide_for_diller?
    !%w[диллер].include?(user.role)
  end

  def only_for_agent?
    %w[агент].include?(user.role)
  end

  def hide_for_agent?
    !%w[агент].include?(user.role)
  end
end
