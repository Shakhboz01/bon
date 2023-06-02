class UsersController < ApplicationController
  include Pundit

  def index
    authorize User, :manage?

    @users = User.all.order(active_user: :desc).order(:name)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: 'User was Успешно создано.'
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
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_path, notice: 'User was Успешно обновлено.'
    else
      render :edit
    end
  end

  def destroy
    authorize User, :manage?

    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path, notice: 'User was успешно удален.'
  end

  def toggle_active_user
    authorize User, :manage?

    @user = User.find(params[:id])
    if @user.update(active_user: !@user.active_user)
      flash[:success] = 'Статус успешно обновлен'
    else
      flash[:error] = 'Не удалось обновить статус'
    end
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :allowed_to_use, :daily_payment, :password_confirmation, :role, :active_user)
  end
end
