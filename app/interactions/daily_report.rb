# source of income: transactionHistory(sale_id not nil), Sale, ownersOperation
# source of outcome: Expenditure, TransactionHistory, Discount, Salary, DeliveryFromCounterparty, ownersOperation
include ActionView::Helpers
class DailyReport < ActiveInteraction::Base
  def execute
    yesterday_start = DateTime.yesterday.beginning_of_day
    yesterday_end = DateTime.yesterday.end_of_day

    # source of income:
    sales = Sale.where('sales.created_at >= ?', yesterday_start).where('sales.created_at <= ?', yesterday_end)
    total_price_of_sales_in_usd = sales.price_in_usd.sum(:total_price)
    total_price_of_sales_in_uzs = sales.price_in_uzs.sum(:total_price)

    total_profit_of_sales_in_usd = sales.joins(:product_sells).where('sales.price_in_usd = ?', true).sum(:total_profit)
    total_profit_of_sales_in_uzs = sales.joins(:product_sells).where('sales.price_in_usd = ?', false).sum(:total_profit)
    total_paid_of_sales_in_usd = sales.price_in_usd.sum(:total_paid)
    total_paid_of_sales_in_uzs = sales.price_in_uzs.sum(:total_paid)

    transaction_histories = TransactionHistory.where('created_at >= ?', yesterday_start).where('created_at <= ?', yesterday_end)
    sales_that_is_not_yesterdays =
      transaction_histories.where.not(sale_id: nil)
                           .where.not(sale_id: sales.pluck(:id))
    sales_that_is_not_yesterdays_in_usd = sales_that_is_not_yesterdays.price_in_usd.sum(:price)
    sales_that_is_not_yesterdays_in_uzs = sales_that_is_not_yesterdays.price_in_uzs.sum(:price)

    owners_operations = OwnersOperation.where('created_at >= ?', yesterday_start).where('created_at <= ?', yesterday_end)
    debt_operations = DebtOperation.where('created_at >= ?', yesterday_start).where('created_at <= ?', yesterday_end)
    owners_operations_income_in_usd = owners_operations.приход.price_in_usd.sum(:price)
    owners_operations_income_in_uzs = owners_operations.приход.price_in_uzs.sum(:price)
    debt_operations_income_in_uzs = debt_operations.приём.price_in_uzs.sum(:price)
    debt_operations_income_in_usd = debt_operations.приём.price_in_usd.sum(:price)


    # source_of_outcome
    delivery_from_counterparties = DeliveryFromCounterparty.where('created_at >= ?', yesterday_start).where('created_at <= ?', yesterday_end)
    delivery_from_counterparties_in_usd = delivery_from_counterparties.price_in_usd.sum(:total_price)
    delivery_from_counterparties_in_uzs = delivery_from_counterparties.price_in_uzs.sum(:total_price)
    total_paid_of_delivery_from_counterparties_in_usd = delivery_from_counterparties.price_in_usd.sum(:total_paid)
    total_paid_of_delivery_from_counterparties_in_uzs = delivery_from_counterparties.price_in_uzs.sum(:total_paid)

    expenditures = Expenditure.where('created_at >= ?', yesterday_start).where('created_at <= ?', yesterday_end)
    expenditures_in_usd = expenditures.price_in_usd.sum(:price)
    expenditures_in_uzs = expenditures.price_in_uzs.sum(:price)
    total_paid_expenditures_in_usd = expenditures.price_in_usd.sum(:total_paid)
    total_paid_expenditures_in_uzs = expenditures.price_in_uzs.sum(:total_paid)


    # tr_history:
    # expenditures_that_is_not_yesterdays =
    #   transaction_histories.where.not(expenditure_id: nil)
    #                        .where.not(expenditure_id: expenditures.pluck(:id))
    # expenditures_that_is_not_yesterdays_in_usd = expenditures_that_is_not_yesterdays.price_in_usd.sum(:price)
    # expenditures_that_is_not_yesterdays_in_uzs = expenditures_that_is_not_yesterdays.price_in_uzs.sum(:price)

    # delivery_from_cunterparties_that_is_not_yesterdays =
    #   transaction_histories.where.not(delivery_from_cunterparty_id: nil)
    #                        .where.not(delivery_from_cunterparty_id: delivery_from_counterparties.pluck(:id))

    # delivery_from_cunterparties_that_is_not_yesterdays_in_usd = delivery_from_cunterparties_that_is_not_yesterdays.price_in_usd.sum(:price)
    # delivery_from_cunterparties_that_is_not_yesterdays_in_uzs = delivery_from_cunterparties_that_is_not_yesterdays.price_in_uzs.sum(:price)


    # owners:
    owners_operations_outcome_in_usd = owners_operations.расход.price_in_usd.sum(:price)
    owners_operations_outcome_in_uzs = owners_operations.расход.price_in_uzs.sum(:price)
    debt_operations_outcome_in_uzs = debt_operations.отдача.price_in_uzs.sum(:price)
    debt_operations_outcome_in_usd = debt_operations.отдача.price_in_usd.sum(:price)

    # overall:
    overall_income_in_usd =
      transaction_histories.where.not(sale_id: nil).price_in_usd.sum(:price) + owners_operations_income_in_usd + debt_operations_income_in_usd
    overall_income_in_uzs =
      transaction_histories.where.not(sale_id: nil).price_in_uzs.sum(:price) + owners_operations_income_in_uzs + debt_operations_income_in_uzs

    # total_outcome
    overall_outcome_in_usd =
      transaction_histories.where(sale_id: nil).price_in_usd.sum(:price) + owners_operations_outcome_in_usd + debt_operations_outcome_in_usd
    overall_outcome_in_uzs =
      transaction_histories.where(sale_id: nil).price_in_uzs.sum(:price) + owners_operations_outcome_in_uzs + debt_operations_outcome_in_uzs


    message =
      "<b>ОТЧЁТ ПО: #{yesterday_start.to_date}:</b>\n\n" \
      "Итого приход денег:      #{num_to_usd overall_income_in_uzs}  +  #{number_to_currency overall_income_in_usd}\n" \
      "Итого уход денег:          #{num_to_usd overall_outcome_in_uzs}  +  #{number_to_currency overall_outcome_in_usd}\n" \
      "Остаток:                      #{num_to_usd(overall_income_in_uzs - overall_outcome_in_uzs)}  +  #{number_to_currency(overall_income_in_usd - overall_outcome_in_usd)}\n"
    SendMessageJob.perform_later(message)
    # total_income based_on_kassir
    # total_outcome based_on_kassir

    # number of discounts made that day
  end
end
