module SessionsHelper

  def log_in(user)
    session[:user_id] = user.id
    # Guard against session replay attacks
    # See https://bit.ly/33UvK0w for more information
    session[:session_token] = user.session_token;
  end

  # Returns the current logged-in user (if any)
  def current_user
    if session[:user_id]
      user = User.find_by(id: session[:user_id])
      if user && session[:session_token] == user.session_token
        @current_user = user
      end
    elsif cookies.encrypted[:user_id]
      user = User.find_by(id: cookies.encrypted[:user_id])
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Check if a user is logged-in
  def logged_in?
    !current_user.nil?
  end

  # Logs out the current user
  def log_out
    forget(current_user)
    reset_session
    @current_user = nil
  end

  # Remembers a user in a persistent session
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Forgets a persistent session
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Return true if the given user is the current user
  def current_user?(user_id)
    user = User.find_by(id: user_id)
    user && user == current_user
  end

end
