module SessionHelper
  def log_in(user)
    # Session method lets us save the user id on the cookies, and automatically it encripts it
    session[:user_id] = user.id
    # Guard against session replay attacks.
    # See https://bit.ly/33UvK0w for more.
    session[:session_token] = user.session_token
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember
    # permanent sets the expire date to 20 years from now.
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user
    # basically assigns user_id to the session cookie and then checks if it exists
    if (user_id = session[:user_id])
      user = User.find_by(id: user_id)
      @current_user = user if user && session[:session_token] == user.session_token
      # basically if current user is nil or false the asignation will happend. If it isn't the assignation will not happen
      # @current_user ||= User.find_by(id: session[:user_id])
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the given user is the current user.
  def current_user?(user)
    user && user == current_user
  end

  # function to know if the user is logged in
  def logged_in?
    !current_user.nil?
  end

  # Forgets a persistent session
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user
  def log_out
    forget(current_user)
    # Resets all sessions variables
    reset_session
    @current_user = nil
  end
end
