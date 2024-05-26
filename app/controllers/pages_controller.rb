class PagesController < ApplicationController
  before_action :set_buyers, only: %i[main_page maps_page]

  def main_page
    @providers = Provider.where(active: true).order(weight: :desc)
  end

  def define_sale_destination; end

  def shortcuts; end

  def daily_report
    DailyReport.run
    respond_to do |format|
      format.json { render json: {success: true}, status: :ok }
      format.html { redirect_to request.referrer || root_path }
    end
  end

  def qr_scanner; end

  def admin_page
    authorize PagesController, :access?

    @q = DeliveryFromCounterparty.ransack(params[:q])
    # @delivery_from_counterparties = @q.result
    # @product_categories = ProductCategory.where(weight: 0)
    # @local_category_info = []
    # @product_categories.each do |product_category|
    #   money_given_in_usd =
    #     @delivery_from_counterparties.where(product_category_id: product_category.id)
    #                                  .price_in_usd.sum(:total_paid)
    #   money_given_in_uzs =
    #     @delivery_from_counterparties.where(product_category_id: product_category.id)
    #                                  .price_in_uzs.sum(:total_paid)
    #   product_taken_in_usd =
    #     @delivery_from_counterparties.where(product_category_id: product_category.id)
    #                                  .price_in_usd.sum(:total_price)
    #   product_taken_in_uzs =
    #     @delivery_from_counterparties.where(product_category_id: product_category.id)
    #                                  .price_in_usd.sum(:total_price)
    #   overall = {
    #     category: product_category.name,
    #     money_given_in_usd: money_given_in_usd,
    #     money_given_in_uzs: money_given_in_uzs,
    #     product_taken_in_usd: product_taken_in_usd,
    #     product_taken_in_uzs: product_taken_in_uzs,
    #     difference_in_usd: money_given_in_usd - product_taken_in_usd,
    #     difference_in_uzs: money_given_in_uzs - product_taken_in_uzs
    #   }
    #   @local_category_info.push(overall)
    # end

    # @import_category_info = []
    # import_product_category = ProductCategory.find_by(weight: 1)
    # product_taken_in_usd =
    #   @delivery_from_counterparties.where(product_category_id: import_product_category.id)
    #                                .price_in_usd.sum(:total_price)
    # money_given_in_usd =
    #   @delivery_from_counterparties.where(product_category_id: import_product_category.id)
    #                                .price_in_usd.sum(:total_paid)
    # @import_category_info.push({
    #   category: import_product_category.name,
    #   money_given_in_usd: money_given_in_usd,
    #   product_taken_in_usd: product_taken_in_usd,
    #   difference_in_usd: money_given_in_usd - product_taken_in_usd
    # })

    # overall_info
    # overall_info
    product_sells = ProductSell.ransack(params[:q]).result
    sales = Sale.ransack(params[:q]).result
    delivery_from_counterparties = DeliveryFromCounterparty.ransack(params[:q]).result
    expenditures = Expenditure.ransack(params[:q]).result
    salaries = Salary.ransack(params[:q]).result

    @sales_in_usd = sales.price_in_usd.sum(:total_paid)
    @sales_in_uzs = sales.price_in_uzs.sum(:total_paid)

    # @delivery_from_counterparties_in_usd = delivery_from_counterparties.price_in_usd.sum(:total_paid)
    # @delivery_from_counterparties_in_uzs = delivery_from_counterparties.price_in_uzs.sum(:total_paid)
    rate = CurrencyRate.last.rate
    # @delivery_from_counterparties_in_uzs += (rate * @delivery_from_counterparties_in_usd)
    @expenditures_in_usd = expenditures.price_in_usd.sum(:price)
    @expenditures_in_uzs = expenditures.price_in_uzs.sum(:price)

    @prepayment = salaries.where(prepayment: true).sum(:price)
    @salaries = salaries.where(prepayment: false).sum(:price)

    # calculate profit
    sales = sales.left_outer_joins(:product_sells)
                 .where(product_sells: { id: nil })
                 .where.not(total_price: 0).where(total_paid:0)

    sale_total_price = sales.sum(:total_price)
    sale_total_paid = sales.sum(:total_paid)
    unpaid_difference_in_percent_in_usd = sales.where('sales.price_in_usd = ?', true).sum(:total_paid) * 100 / sales.where('sales.price_in_usd = ?', true).sum(:total_price)
    unpaid_difference_in_percent_in_uzs = sales.where('sales.price_in_usd = ?', false).sum(:total_paid) * 100 / sales.where('sales.price_in_usd = ?', false).sum(:total_price)

    @overall_income_in_usd = @sales_in_usd - (@expenditures_in_usd)
    @overall_income_in_uzs = @sales_in_uzs - (@prepayment + @salaries + @expenditures_in_uzs)
  end

  def maps_page; end

  private

  def set_buyers
    @buyers =
      if %w[админ менеджер].include?(current_user.role)
        Buyer.all
      else
        current_user.agent_buyers
      end

    @buyers = @buyers.where(active: true).order(name: :desc)
  end
end
