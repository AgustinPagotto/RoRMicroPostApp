class StaticPagesController < ApplicationController
  def home
    return unless logged_in?

    # Generates a micropost for the form
    @micropost = current_user.microposts.build
    # Brings the feed of posts for the user
    @feed_items = current_user.feed.paginate(page: params[:page])
  end

  def help; end

  def about; end

  def contact; end
end
