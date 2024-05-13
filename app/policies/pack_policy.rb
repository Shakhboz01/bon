class PackPolicy < ApplicationPolicy
  def access?
    everyone_is_allowed?
  end

  def manage?
    user_is_accaontant?
  end
end
