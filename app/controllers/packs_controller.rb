class PacksController < ApplicationController
  before_action :set_pack, only: %i[ toggle_active show edit update destroy calculate_product_remaining update_buy_price]
  include Pundit::Authorization

  def toggle_active
    authorize Pack, :manage?

    @pack.toggle(:active).save
    redirect_to packs_url, notice: "Successfully updated"
  end

  # GET /packs or /packs.json
  def index
    authorize Pack, :access?

    @q = Pack.all.ransack(params[:q])
    @packs = @q.result.order(active: :desc).order(name: :asc)
    @all_packs = @packs.where(active: true).where('initial_remaining > 0')
    @packs = @packs.page(params[:page]).per(40)
  end

  # GET /packs/1 or /packs/1.json
  def show
  end

  # GET /packs/new
  def new
    @pack = Pack.new
  end

  # GET /packs/1/edit
  def edit; end

  # POST /packs or /packs.json
  def create
    authorize Pack, :manage?

    @pack = Pack.new(pack_params)
    delivery = DeliveryFromCounterparty.where(id: pack_params['delivery_id']).last

    respond_to do |format|
      if @pack.save
        if !pack_params['delivery_id'].empty?
          format.html { redirect_to delivery_from_counterparty_url(delivery, pack_id: @pack.id), notice: "Pack was successfully created." }
        else
          format.html { redirect_to packs_url, notice: "Pack was successfully created." }
        end

        format.json { render :show, status: :created, location: @pack }
      else
        format.html { redirect_to request.referrer, notice: @pack.errors.messages.values.join(' | ') }
        format.json { render json: @pack.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /packs/1 or /packs/1.json
  def update
    authorize Pack, :manage?

    respond_to do |format|
      if @pack.update(pack_params)
        format.html { redirect_to packs_url, notice: "Pack was successfully updated." }
        format.json { render :show, status: :ok, location: @pack }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pack.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /packs/1 or /packs/1.json
  def destroy
    authorize Pack, :manage?

    @pack.destroy
    respond_to do |format|
      format.html { redirect_to packs_url, notice: "Pack was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def filtered_packs
    code_value = params[:code_value].downcase.strip
    @filtered_packs = Pack.where("lower(code) LIKE ? OR lower(barcode) LIKE ?", "%#{code_value}%", "%#{code_value}%")
    respond_to do |format|
      format.js # assuming you have a corresponding js.erb file for the response
    end
  end

  def calculate_product_remaining
    render json: { calculate_product_remaining: @pack.initial_remaining }
  end

  def update_buy_price
    authorize Pack, :manage?

    Packs::UpdateBuyPrice.run!(pack: @pack)
    redirect_to request.referrer, notice: 'Narx o\'zgartirildi'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pack
      @pack = Pack.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def pack_params
      params.require(:pack).permit(
        :name, :code, :barcode, :delivery_id, :buy_price, :sell_price, :price_in_usd, :initial_remaining,
        :product_category_id, :weight, :image,
        product_size_colors_attributes: [:size, :color_id, :amount]
      )
    end
end
