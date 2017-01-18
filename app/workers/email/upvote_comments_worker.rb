class UpvoteCommentsWorker
  include Sidekiq::Worker
  include MeedPointsTransactionManager
  include CommentsManager
  include FeedItemsManager

  sidekiq_options retry: true, :queue => :default
  def perform(comment_id, handle)
    comment = get_comment_id(comment_id)
    if comment.blank?
      return
    end
    update_feed_update_date(comment.feed_id)
    create_notification(comment.poster_id, handle, comment.feed_id, MeedNotificationType::UPVOTE_COMMENT)
    user = get_user_by_handle(comment.poster_id)
    giver_user = get_user_by_handle(handle)
    Notifier.email_comment_upvote(giver_user, user, comment).deliver
  end

end