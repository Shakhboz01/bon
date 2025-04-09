class SalePortionsController < ApplicationController
  before_action :set_sale_portion, only: %i[ show edit update destroy ]

  # GET /sale_portions or /sale_portions.json
  def index
    @sale_portions = SalePortion.all
  end

  # GET /sale_portions/1 or /sale_portions/1.json
  def show

  end

  # GET /sale_portions/new
  def new
    @sale_portion = SalePortion.new(till: DateTime.now)
  end

  # GET /sale_portions/1/edit
  def edit
  end

  # POST /sale_portions or /sale_portions.json
  def create
    @sale_portion = SalePortion.new(sale_portion_params)
    @sale_portion.user_id = current_user.id
    respond_to do |format|
      if @sale_portion.save
        format.html { redirect_to sale_portion_url(@sale_portion), notice: "Sale portion was successfully created." }
        format.json { render :show, status: :created, location: @sale_portion }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sale_portion.errors, status: :unprocessable_entity }
      end
    end
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
