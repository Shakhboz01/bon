class DeliveryFromCounterpartyPolicy < ApplicationPolicy
  def access?
    user_is_manager?
  end

  def manage?
    user_is_accaontant?
  end

  def toggle_status?
    user_is_skladchik?
  end
end
