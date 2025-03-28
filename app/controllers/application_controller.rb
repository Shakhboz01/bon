class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def verify_by_telegram_chat_authorized
    return render json: { success: false } unless params[:telegram_chat_id]

    user = User.find_by(telegram_chat_id: params[:telegram_chat_id])
    return if user

    render json: { success: false }
  end


  private

  def user_not_authorized
    flash[:alert] = 'Вам не разрешено совершить эту операцию.'
    redirect_to(request.referrer || root_path)
  end

  protected

  def after_sign_in_path_for(resource)
    if resource.дилер? # Replace :дилер with the actual role check
      qr_scanner_path
    else
      super
    end
  end
end
