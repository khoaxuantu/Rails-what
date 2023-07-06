class UsersController < ApplicationController
  before_action :login_required, only: %i[index edit update destroy following followers]
  before_action :correct_user, only: %i[edit update]
  before_action :get_user_by_id, only: %i[show edit update following followers]

  def index
    @pagy, @users = pagy(User.activated_users)
  end

  def new
    @user = User.new
  end

  def show
    @pagy, @microposts = pagy(@user.microposts.latest)
    return redirect_to root_url unless @user.activated?
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @user.send_activation_email
      flash[:info] = t 'flash.email_activation'
      redirect_to root_url
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = t 'flash.profile_updated'
      redirect_to @user
    else
      render 'edit', status: :bad_request
    end
  end

  def destroy
    @user.destroy
    flash[:success] = t 'flash.user_deleted'
    redirect_to users_url
  end

  def following
    @title = t 'relationships.following'
    @pagy, @users = pagy(@user.following)
    render 'show_follow', status: :unprocessable_entity
  end

  def followers
    @title = t 'relationships.followers'
    @pagy, @users = pagy(@user.followers)
    render 'show_follow', status: :unprocessable_entity
  end

  def correct_user
    redirect_to(root_url, status: :bad_request) unless
    current_user?(params[:id])
  end

  def get_user_by_id
    @user = User.find_by(id: params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
      :password_confirmation)
  end

end
