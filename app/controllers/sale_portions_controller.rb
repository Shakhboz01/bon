class SalePortionsController < ApplicationController
  before_action :set_sale_portion, only: %i[ show edit update destroy verify_by_factory ]

  # GET /sale_portions or /sale_portions.json
  def index
    @q = SalePortion.ransack(params[:q])
    @sale_portions = @q.result.includes(:user).order(id: :desc).page(params[:page]).per(40)
  end

  # GET /sale_portions/1 or /sale_portions/1.json
  def show
    @sales = SalePortion.sales(@sale_portion.from, @sale_portion.till)
                        .where.not(total_price: 0)
                        .includes(:buyer, :user).order(id: :desc)
    if @sale_portion.user_id
      @sales = @sales.where(agent_user: User.find(@sale_portion.user_id))
    end

    @grouped_packs = ProductSell.joins(:pack).where(sale_id: @sales.pluck(:id)).group('packs.name').sum('amount')
    @total_price = @sales.sum(:total_price)
  end

  # GET /sale_portions/new
  def new
    authorize SalePortion, :access?
    unless params.dig(:q, :created_at_gteq)
      params[:q] ||= {}
      params[:q][:created_at_gteq] = DateTime.current.beginning_of_day
    end

    unless params.dig(:q, :created_at_end_of_day_lteq)
      params[:q][:created_at_end_of_day_lteq] = DateTime.current.end_of_day
    end

    @sale_portion = SalePortion.new(
      from: params.dig(:q, :created_at_gteq),
      till: params.dig(:q, :created_at_end_of_day_lteq),
      user_id: params.dig(:q, :agent_user_id_eq)
    )
    @q = Sale.ransack(params[:q])
    @sales = @q.result.where.not(total_price: 0).includes(:buyer, :user)
                        .order(id: :desc)
    if params.dig(:q_other, :agent_user_id_eq)
      @sales = @sales.where(agent_user: User.find(params.dig(:q_other, :agent_user_id_eq)))
    end

    @grouped_packs = ProductSell.joins(:pack).where(sale_id: @sales.pluck('sales.id')).group('packs.name').sum('amount')
    @total_price = @sales.sum(:total_price)
  end

  # GET /sale_portions/1/edit
  def edit
  end

  # POST /sale_portions or /sale_portions.json
  def create
    authorize SalePortion, :access?

    @sale_portion = SalePortion.new(sale_portion_params)
    respond_to do |format|
      if @sale_portion.save
        format.html { redirect_to sale_portions_url(@sale_portion), notice: "successfully created." }
        format.json { render :show, status: :created, location: @sale_portion }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sale_portion.errors, status: :unprocessable_entity }
      end
    end
  end

  def export_excel
    @q = Sale.ransack(params[:q])
    @sales = @q.result.where.not(total_price: 0).includes(:buyer, :user)
                      .order(id: :desc)

    if params.dig(:q_other, :agent_user_id_eq)
      @sales = @sales.where(agent_user: User.find(params.dig(:q_other, :agent_user_id_eq)))
    end

    @grouped_packs = ProductSell.joins(:pack).where(sale_id: @sales.pluck(:id)).group('packs.name').sum('amount')
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=export_#{Time.now.strftime('%Y%m%d%H%M')}.xlsx"
      }
    end
  end

  def verify_by_factory
    authorize SalePortion, :manage?

    @sale_portion.update(verified_by_factory: true)
    redirect_to sale_portions_url, notice: 'Остаток склада изменены'
  end

  # PATCH/PUT /sale_portions/1 or /sale_portions/1.json
  def update
    respond_to do |format|
      if @sale_portion.update(sale_portion_params)
        format.html { redirect_to sale_portion_url(@sale_portion), notice: "Sale portion was successfully updated." }
        format.json { render :show, status: :ok, location: @sale_portion }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sale_portion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sale_portions/1 or /sale_portions/1.json
  def destroy
    @sale_portion.destroy

    respond_to do |format|
      format.html { redirect_to sale_portions_url, notice: "Sale portion was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sale_portion
      @sale_portion = SalePortion.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sale_portion_params
      params.require(:sale_portion).permit(:from, :till, :user_id)
    end
end
