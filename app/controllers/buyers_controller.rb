class BuyersController < ApplicationController
  before_action :set_buyer, only: %i[ toggle_active show edit update destroy toggle_active ]

  # GET /buyers or /buyers.json
  def index
    @q = Buyer.ransack(params[:q])
    @buyers = @q.result.order(active: :desc).page(params[:pahe]).per(40)
  end

  # GET /buyers/1 or /buyers/1.json
  def show
  end

  # GET /buyers/new
  def new
    @buyer = Buyer.new
  end

  # GET /buyers/1/edit
  def edit
  end

  # POST /buyers or /buyers.json
  def create
    @buyer = Buyer.new(buyer_params.except(:images))

    respond_to do |format|
      if @buyer.save
        format.html { redirect_to buyers_url, notice: "Buyer was successfully created." }
        format.json { render :show, status: :created, location: @buyer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @buyer.errors, status: :unprocessable_entity }
      end

      @buyer.save_images_to_temporary_location(buyer_params[:images], @buyer)
    end
  end

  # PATCH/PUT /buyers/1 or /buyers/1.json
  def update
    respond_to do |format|
      if @buyer.update(buyer_params)
        format.html { redirect_to buyers_url, notice: "Buyer was successfully updated." }
        format.json { render :show, status: :ok, location: @buyer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @buyer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /buyers/1 or /buyers/1.json
  def destroy
    @buyer.destroy

    respond_to do |format|
      format.html { redirect_to buyers_url, notice: "Buyer was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def toggle_active
    @buyer.toggle(:active).save
    redirect_to request.referrer || buyers_path, notice: "Successfully updated"
  end

  def statistics
    @q = Sale.ransack(params[:q])
    @sales = @q.result.joins(:buyer).group('buyers.name').sum(:total_price)

    # Sort the sales by total_price in descending order
    @top_buyers = @sales.sort_by { |buyer_name, total_price| total_price }.reverse
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_buyer
    @buyer = Buyer.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def buyer_params
    params.require(:buyer).permit(
      :name, :phone_number, :comment, :active, :debt_in_uzs, :debt_in_usd,
      :longitude, :latitude, :address, :agent_user_id, :diller_user_id,
      images: []
      )
  end
end
