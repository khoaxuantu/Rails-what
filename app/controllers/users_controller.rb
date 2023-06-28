class UsersController < ApplicationController
  before_action :login_required, only: [:edit, :update]
  before_action :correct_user, only: [:edit, :update]

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)

    if @user.save
      reset_session
      log_in @user
      # Handle a successful save
      flash[:success] = "Welcome to the Sample App"
      redirect_to user_url(@user)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      # Handle a successful update
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit', status: :bad_request
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  def login_required
    unless logged_in?
      flash[:danger] = "Login required."
      redirect_to login_url, status: :unauthorized
    end
  end

  def correct_user
    redirect_to(root_url, status: :bad_request) unless
      current_user?(params[:id])
  end

  private :user_params
end
