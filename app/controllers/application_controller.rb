class ApplicationController < ActionController::Base
  before_action :require_login
  add_flash_types :success, :danger

  private

  def require_login
    unless user_signed_in?
      redirect_to login_path, alert: "ログインが必要です"
    end
  end
end
