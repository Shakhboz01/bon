class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = 'Вам не разрешено совершить эту операцию.'
    redirect_to(request.referrer || root_path)
  end

  protected

  def after_sign_in_path_for(resource)
    if resource.диллер? # Replace :диллер with the actual role check
      qr_scanner_path
    else
      super
    end
  end
end
