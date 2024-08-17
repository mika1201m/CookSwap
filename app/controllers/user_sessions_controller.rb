class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new; end

  def create
    @user = login(params[:email], params[:password], params[:password_confirmation])

    if @user
      redirect_to user_top_path, success: t('defaults.flash_message.logged_in')
    else
      redirect_to login_path, flash: { danger: t('defaults.flash_message.not_logged_in') }    end
  end

  def destroy
    logout
    redirect_to root_path, status: :see_other, success: t('defaults.flash_message.logout')
  end
end
