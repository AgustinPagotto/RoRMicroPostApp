module SessionHelper
  def log_in(user)
    # Session method lets us save the user id on the cookies, and automatically it encripts it
    session[:user_id] = user.id
  end

  def current_user
    return unless session[:user_id]

    # Basically if current user is nil or false the asignation will happend. If it isn't the assignation will not happen
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # function to know if the user is logged in
  def logged_in?
    !current_user.nil?
  end

  # Logs out the current user
  def log_out
    # Resets all sessions variables
    reset_session
    @current_user = nil
  end
end
