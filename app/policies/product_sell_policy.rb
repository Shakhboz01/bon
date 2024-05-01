class ProductSellPolicy < ApplicationPolicy
  def create?
    user_is_agent?
  end

  def manage?
    user_is_accaontant?
  end
end
