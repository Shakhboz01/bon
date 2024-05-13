class DeliveryFromCounterpartyPolicy < ApplicationPolicy
  def access?
    user_is_skladchik?
  end

  def manage?
    user_is_skladchik?
  end
end
