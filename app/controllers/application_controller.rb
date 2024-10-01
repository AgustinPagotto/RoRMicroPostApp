class ApplicationController < ActionController::Base
  include SessionHelper

  private

  # Confirms a logged-in user.
  def logged_in_user
    return if logged_in?

    flash[:danger] = 'Please log in.'
    redirect_to login_url, status: :see_other
  end
end
