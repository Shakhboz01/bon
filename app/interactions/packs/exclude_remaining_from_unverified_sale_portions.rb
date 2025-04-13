module Packs
  class ExcludeRemainingFromUnverifiedSalePortions < ActiveInteraction::Base
    def execute
      last_portion = SalePortion.order(created_at: :desc).first
      return {} if last_portion.nil?

      sales_out_of_sale_portions = Sale.where('created_at > ?', last_portion.till)
      # Step 1: Get all ranges
      ranges = SalePortion.where(verified_by_factory: false).pluck(:from, :till)

      # Step 2: Build a combined condition using OR for each range
      sales_scope = Sale.none

      ranges.each do |from, till|
        sales_scope = sales_scope.or(Sale.where(created_at: from..till))
      end

      sales_scope = sales_scope.or(Sale.where(id: sales_out_of_sale_portions.pluck(:id)))

      # Step 3: Group and sum
      sales_scope.joins(:product_sells).group('product_sells.pack_id').sum('product_sells.amount')
    end
  end
end
