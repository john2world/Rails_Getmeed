class FeedItemsController < ApplicationController
  before_filter :logged_in?
  before_filter :require_moderator

  def downvote
    if UserDownvote.from_user(current_user).downvote FeedItems.find_by(id: params[:id])
      head :ok
    else
      head :not_acceptable
    end
  end
end
