class BuyersController < ApplicationController
  before_action :set_buyer, only: %i[ webview_sale_form toggle_active show edit update destroy toggle_active ]
  before_action :verify_by_telegram_chat_authorized, only: %i[list_buyers]
  skip_before_action :authenticate_user!, only: %i[list_buyers create_via_telegram_bot webview_sale_form]
  skip_before_action :verify_authenticity_token, only: %i[list_buyers create_via_telegram_bot]
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
        format.html { redirect_to root_path, notice: "Buyer was successfully created." }
        format.json { render :show, status: :created, location: @buyer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @buyer.errors, status: :unprocessable_entity }
      end

      @buyer.save_images_to_temporary_location(buyer_params[:images], @buyer)
    end
  end

  def create_via_telegram_bot
    user = User.find_by(telegram_chat_id: params[:telegram_chat_id])
    render json: { error: "User not found" }, status: :not_found unless user

    buyer = Buyer.new(
      agent_user: user,
      diller_user: User.find(params[:agent_diller_id]),
      debt_in_usd: '',
      debt_in_uzs: '',
      name: params[:name],
      phone_number: params[:phone],
      comment: params[:comment],
      longitude: params[:longitude],
      latitude: params[:latitude],
      address: params[:address]
    )

    if buyer.save
      render json: { message: "Buyer created" }, status: :created
    else
      render json: { error: buyer.errors.full_messages }, status: :unprocessable_entity
    end
  end

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

  def list_buyers
    query = params[:query].to_s.strip
    lat = params[:latitude].to_f
    lon = params[:longitude].to_f

    buyers = Buyer.where(active: true)
    buyers = buyers.where("name ILIKE ?", "%#{query}%") if query.present?

    if lat.nonzero? && lon.nonzero?
      buyers = buyers.order(Arel.sql("((latitude - #{lat})^2 + (longitude - #{lon})^2) ASC"))
    end

    render json: { success: true, buyers: buyers.select(:id, :name, :longitude, :latitude, :address) }
  end

  def webview_sale_form
    user = User.find_by(telegram_chat_id: params[:telegram_chat_id])
    return render plain: "Unauthorized", status: :unauthorized unless user&.агент?

    @sale = Sale.new(
      buyer_id: @buyer.id,
      user_id: user.id,
      status: :processing,
      total_price: 0,
      total_paid: 0,
      diller_user: @buyer.diller_user,
      agent_user: user,
      verified_by_agent: true,
      price_in_usd: false
    )
    @categories = ProductCategory.includes(:packs).where(packs: { active: true }).order(:name)
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
