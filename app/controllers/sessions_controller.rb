class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # Log the user in and redirect to the user's show page
      reset_session
      log_in user
      remember user
      redirect_to user
    else
      # Return error
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    # We need to check an user logged in first. In case users are logging in multiple
    # browsers, if they log out in 1 browser then the app in other browsers
    # should not call log_out
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end
end
