class SalesController < ApplicationController
  before_action :set_sale, only: %i[ nullify show edit update destroy toggle_status html_view edit_agent_or_diller]
  before_action :set_sale_based_on_params, only: %i[ index grouped_html_views grouped_packs massive_status_update ]

  skip_before_action :authenticate_user!, only: %i[webview]
  skip_before_action :verify_authenticity_token, only: %i[webview]
  include Pundit::Authorization
  # GET /sales or /sales.json
  def index
    @sales_data = @sales
    @sales = @sales.page(params[:page]).per(70)
  end

  # GET /sales/1 or /sales/1.json
  def show
    @product_sells = @sale.product_sells.includes(:buyer, :pack, :product)
    @product_sell = ProductSell.new(sale_id: @sale.id)
    @products = Product.active.order(:name)
    @rate = CurrencyRate.last.rate
    @packs = Pack.includes(:product_category).where(active: true).order(weight: :desc)
    @current_user = current_user
  end

  # GET /sales/new
  def new
    @sale = Sale.new
  end

  # GET /sales/1/edit
  def edit
  end

  # POST /sales or /sales.json
  def create
    @sale = Sale.new(sale_params.except(:images))
    @sale.user_id = current_user.id
    respond_to do |format|
      if @sale.save
        format.html { redirect_to sales_url(@sale), notice: "Sale was successfully created." }
        format.json { render :show, status: :created, location: @sale }
        @sale.save_images_to_temporary_location(sale_params[:images], @sale)
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  def webview
    user = User.find_by(telegram_chat_id: params[:telegram_chat_id])
    return render json: { success: false, error: "Unauthorized" }, status: :unauthorized unless user&.агент?

    buyer = Buyer.find_by(id: params[:buyer_id])
    return render json: { success: false, error: "Buyer not found" }, status: :not_found unless buyer

    sales_data = params[:sale]
    return render json: { success: false, error: "Invalid sales data" }, status: :unprocessable_entity if sales_data.blank?

    sale = Sale.new(
      buyer_id: buyer.id,
      user_id: user.id,
      status: :verified_by_agent,
      total_price: 0,
      total_paid: 0,
      diller_user: buyer.diller_user,
      agent_user: user,
      verified_by_agent: true,
      price_in_usd: false
    )

    sales_data.each do |pack_id, amount|
      pack = Pack.find_by(id: pack_id)
      return render json: { success: false, error: "Pack not found" }, status: :not_found unless pack

      sale.product_sells.build(
        pack_id: pack.id,
        amount: amount,
        sell_price: pack.sell_price,
        price_in_usd: false
      )
    end

    if sale.save
      render json: { success: true, sale_id: sale.id }
    else
      render json: { success: false, errors: sale.errors.full_messages }
    end
  end

  # PATCH/PUT /sales/1 or /sales/1.json
  def update
    currency_was_in_usd = @sale.price_in_usd

    if @sale.update(sale_params.except(:images).merge(status: sale_params[:status].to_i))
      handle_redirect(currency_was_in_usd, @sale.price_in_usd)
      @sale.save_images_to_temporary_location(sale_params[:images], @sale)
    else
      redirect_to request.referrer, notice: @sale.errors.messages.values
    end
  end

  # DELETE /sales/1 or /sales/1.json
  def destroy
    authorize Sale, :manage?

    @sale.destroy

    respond_to do |format|
      format.html { redirect_to sales_url, notice: "Sale was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def default_create
    return request.referrer unless params[:buyer_id].present?

    buyer = Buyer.find(params[:buyer_id])
    last_one = buyer.sales.order(created_at: :asc).last
    if !last_one.nil? && last_one.processing?
      if last_one.product_sells.empty?
        last_one.update(created_at: DateTime.current, user_id: current_user.id)
      end

      last_one.update(user_id: current_user.id)
      redirect_to sale_url(last_one)
    else
      if current_user.агент?
        agent_user_id = current_user.id
      else
        agent_user_id = buyer.agent_user_id
      end
      sfs = Sale.new(
        buyer: buyer,
        user: current_user,
        price_in_usd: ENV.fetch('PRICE_IN_USD'),
        diller_user_id: buyer.diller_user_id,
        agent_user_id: agent_user_id
      )
      if sfs.save
        redirect_to sale_url(sfs)
      else
        redirect_to request.referrer, notice: "Something went wrong"
      end
    end
  end

  def toggle_status
    authorize Sale, :manage?

    @sale.update(status: @sale.closed? ? 0 : 1)
    if @sale.processing?
      message = "&#9888 Заверщённая продажа № <a href=\"#{ENV.fetch('HOST_URL')}/sales/#{@sale.id}\">#{@sale.id}</a> была снова открыта!\n" \
        "Пожалуйста, уточните причину переоткрытия!\n"
        "Нажмите <a href=\"#{ENV.fetch('HOST_URL')}/sales/#{@sale.id}\">здесь</a> для просмотра"
      SendMessageJob.perform_later(message)
    end

    redirect_to sale_path(@sale)
  end

  def excel
    @sales = Sale.where(id: params[:sales_data][:sale_ids].split(','))
                 .order(created_at: :desc)
  end

  def pdf_view
    @file_path = params[:file_path]
  end

  def html_view
    @total_debt_in_uzs = @sale.buyer.calculate_debt_in_uzs
    # current_total_price = @sale.total_price - @sale.total_paid
    # @debt_with_exception = @total_debt - current_total_price
  end

  def edit_agent_or_diller
    authorize Sale, :manage?
  end

  def grouped_packs
    @total_price = @sales.sum(:total_price)
    @grouped_packs = ProductSell.joins(:pack).where(sale_id: @sales.pluck(:id)).group('packs.name').sum(:amount)
  end

  def grouped_html_views
  end

  def massive_status_update
    authorize Sale, :manage?

    @sales.where(status: 'verified_by_agent').update_all(status: :verified_by_diller)
    redirect_to request.referrer, notice: 'Sccessfully updated!'
  end

  def nullify
    authorize Sale, :manage?

    @sale.product_sells.delete_all
    @sale.update(total_price: 0, total_paid: 0, comment: "#{@sale.comment} ||| аннулировано")
    redirect_to request.referrer, notice: 'аннулировано!'
  end

  private

  def set_sale_based_on_params
    @q = Sale.includes(:buyer, :user).ransack(params[:q])
    @sales = @q.result
  end

  def handle_redirect(previous, current)
    if previous != current
      # It means, currency is changed
      redirect_to request.referrer, notice: "Valyuta o'zgartirildi"
    else
      redirect_to sales_url
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_sale
    @sale = Sale.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def sale_params
    params.require(:sale).permit(
      :total_paid, :payment_type, :buyer_id, :total_price, :comment,
      :user_id, :status, :discount_price, :price_in_usd, :verified_by_agent,
      :diller_user_id, :agent_user_id, images: []
    )
  end
end
