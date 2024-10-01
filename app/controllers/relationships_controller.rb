class RelationshipsController < ApplicationController
  before_action :logged_in_user
  # we handle Turbo requests and regular requests in a unified way using the important respond_to method, in this method only one of the lines gets executed.
  # what happens when we add format.turbo_stream? The answer is that Rails looks for an embedded Ruby template of the form <action>.turbo_stream.erb
  #  If there isn’t any code in the action to respond to a Turbo stream, the request is handled like a regular HTML request.

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      # this will look for a create.turbo_stream.erb in the views
      format.turbo_stream
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user, status: :see_other }
      # this will look for a destroy.turbo_stream.erb in the views
      format.turbo_stream
    end
  end
end
