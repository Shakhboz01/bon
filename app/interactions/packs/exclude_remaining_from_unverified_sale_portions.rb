module Packs
  class ExcludeRemainingFromUnverifiedSalePortions < ActiveInteraction::Base
    def execute
      last_portion = SalePortion.order(created_at: :desc).first
      return {} if last_portion.nil?

      sales_out_of_sale_portions = Sale.where('created_at > ?', last_portion.till)
      # Step 1: Get all ranges
      ranges = SalePortion.where(verified_by_factory: false)

      # Step 2: Build a combined condition using OR for each range
      sales_scope = Sale.none

      ranges.each do |sale_portion|
        if (user_id = sale_portion.user_id)
          user = User.find(user_id)
          sales_scope = sales_scope.or(Sale.where(created_at: sale_portion.from..sale_portion.till).where(agent_user: user))
        else
          sales_scope = sales_scope.or(Sale.where(created_at: sale_portion.from..sale_portion.till))
        end
      end

      sales_scope = sales_scope.or(Sale.where(id: sales_out_of_sale_portions.pluck(:id)))

      # Step 3: Group and sum
      sales_scope.joins(:product_sells).group('product_sells.pack_id').sum('product_sells.amount')
    end
  end
end
