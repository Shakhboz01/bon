class UsersController < ApplicationController
  include Pundit::Authorization

  def index
    @users = User.all.order(active: :desc).order(:name)
  end

  def show
    @user = User.find(params[:id])
  end

  def new_user_form
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
    @user = User.new(user_params)
    @user.email = user_params.name + "@gmail.com"
    @user.password = "1111"
    if @user.save
      redirect_to users_path, notice: "Успешно создано."
    else
      render :new
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

  private

  def user_params
    params.require(:user).permit(:name, :email, :phone_number, :password, :allowed_to_use, :daily_payment, :password_confirmation, :role, :active)
  end
end
