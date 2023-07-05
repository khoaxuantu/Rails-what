class PasswordResetsController < ApplicationController
  before_action :get_user, only: %i[edit update]
  before_action :valid_user, only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new
  end

  def edit
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = I18n.t 'flash.password_reset_email_sent'
      redirect_to root_url
    else
      flash.now[:danger] = I18n.t 'flash.email_not_found'
      render 'new', status: :unprocessable_entity
    end
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty.")
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params)
      reset_session
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = I18n.t 'flash.password_reset_success'
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # Checks expiration of reset token
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = I18n.t 'flash.password_reset_expired'
        redirect_to new_password_reset_url
      end
    end

end
