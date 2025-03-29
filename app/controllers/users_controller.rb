class UsersController < ApplicationController
  include Pundit::Authorization
  # before_action :authenticate_api_request, only: %i[verify_by_telegram_chat_id verify_by_phone_number]
  skip_before_action :authenticate_user!, only: %i[verify_by_telegram_chat_id verify_by_phone_number create_sale]
  skip_before_action :verify_authenticity_token, only: %i[verify_by_telegram_chat_id verify_by_phone_number create_sale]

  def index
    authorize User, :access?

    @users = User.all.order(active: :desc).order(:name)
  end

  def show
    authorize User, :access?

    @user = User.find(params[:id])
  end

  def new_user_form
    authorize User, :access?

    @user = User.new
  end

  def auto_user_creation
    user = User.new(user_params)
    user.email = user.name.split(" ").join + "@gmail.com"
    if user.save
      redirect_to users_path, notice: "Успешно создано."
    else
      redirect_to auto_user_creation_users_path, notice: "error"
    end
  end

  def new
    @user = User.new
  end

  def create
    byebug
    @user = User.new(user_params)
    @user.email = user_params.name + "@gmail.com"
    if @user.save
      redirect_to users_path, notice: "Успешно создано."
    else
      render :new
    end
  end

  def verify_by_phone_number
    user = User.find_by(phone_number: params[:phone_number])
    if user
      user.update(telegram_chat_id: params[:telegram_chat_id])
      render json: { success: true, role: user.role }
    else
      render json: { success: false }
    end
  end

  def verify_by_telegram_chat_id
    user = User.find_by(telegram_chat_id: params[:telegram_chat_id])
    if user
      render json: { success: true, role: user.role }
    else
      render json: { success: false }
    end
  end

  def edit
    authorize User, :manage?
    @user = User.find(params[:id])
  end

  def update
    authorize User, :manage?

    if params[:id] == "auto_user_creation"
      user = User.new(user_params)
      user.email = user.name.split(" ").join + "@gmail.com"
      if user.save
        return redirect_to users_path, notice: "Успешно создано."
      else
        return redirect_to auto_user_creation_users_path, notice: "error"
      end
    end

    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_path, notice: "User was Успешно обновлено."
    else
      render :edit
    end
  end

  def destroy
    authorize User, :manage?

    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path, notice: "User was успешно удален."
  end

  def toggle_active_user
    authorize User, :manage?

    @user = User.find(params[:id])
    if @user.update(active: !@user.active)
      flash[:success] = "Статус успешно обновлен"
    else
      flash[:error] = "Не удалось обновить статус"
    end
    redirect_to users_path
  end

  def create_sale
    user = User.find_by(telegram_chat_id: params[:telegram_chat_id])
    return render json: { success: false, error: "Unauthorized" }, status: :unauthorized unless user&.агент?

    buyer = Buyer.find_by(id: params[:buyer_id])
    return render json: { success: false, error: "Buyer not found" }, status: :not_found unless buyer

    sales_data = params[:sales]
    return render json: { success: false, error: "Invalid sales data" }, status: :unprocessable_entity if sales_data.blank?

    sale = Sale.new(
      buyer_id: buyer.id,
      user_id: user.id,
      status: :processing,
      total_price: 0,
      total_paid: 0,
      diller_user: buyer.diller_user,
      agent_user: user,
      verified_by_agent: true,
      price_in_usd: false
    )

    sales_data.each do |sale_item|
      pack = Pack.find_by(id: sale_item[:pack_id])
      return render json: { success: false, error: "Pack not found" }, status: :not_found unless pack

      sale.product_sells.build(
        pack_id: pack.id,
        amount: sale_item[:amount],
        sell_price: pack.sell_price,
        price_in_usd: false
      )
    end

    if sale.save
      sale.update(status: :verified_by_agent)
      render json: { success: true, sale_id: sale.id }
    else
      render json: { success: false, errors: sale.errors.full_messages }
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :phone_number, :password, :allowed_to_use, :daily_payment, :password_confirmation, :role, :active)
  end

  # def authenticate_api_request
  #   api_token = request.headers['Authorization']
  #   unless api_token && ActiveSupport::SecurityUtils.secure_compare(api_token, 'qwersty')
  #     render json: { success: false, error: 'Unauthorized' }, status: :unauthorized
  #   end
  # end
end
