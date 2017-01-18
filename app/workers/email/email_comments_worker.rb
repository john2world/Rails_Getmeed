class EmailCommentsWorker
  include Sidekiq::Worker
  include CommentsManager
  include FeedItemsManager
  include UsersManager
  include NotificationsManager
  include NotificationsHelper
  sidekiq_options retry: true, :queue => :default


  def perform(comment_id)
    comment = get_comment_id(comment_id)
    if comment.blank?
      return
    end
    content = get_feed_item_for_id(comment.feed_id)
    if content.blank?
      return
    end
    all_comments = get_comments_for_feed(nil, comment.feed_id)
    audience_handles = Array.new
    all_comments.each do |threaded_comment|
      if !comment.poster_id.eql? threaded_comment.poster_id and !content.poster_id.eql? threaded_comment.poster_id
        audience_handles << threaded_comment.poster_id
      end
    end
    all_user_handles = Array.new
    all_user_handles << comment.poster_id
    all_user_handles.concat audience_handles
    all_user_handles << content.poster_id

    user_map = get_users_map_handles(all_user_handles)
    Rails.cache.delete_matched("#{REDIS_KEYS::CACHE_FEED_ITEM_USER_STORIES}*")
    unless comment.poster_id.eql? content.poster_id
      content_owner = user_map[content.poster_id]
      user_map[comment.poster_id][:rank] = get_leaderboard_rank(user_map[comment.poster_id][:meed_points])
      user_settings = UserSettings.find_or_create_by(handle: content.poster_id)
      if user_settings != nil and !user_settings.email_notification_subscription_enabled('social')
        Notifier.email_comment_content_owner(user_map[comment.poster_id], user_map[content.poster_id], comment, content).deliver
      end
      begin
        create_notification(content.poster_id, comment.poster_id, content.id, MeedNotificationType::COMMENT_STORY)
      rescue Exception => ex
        logger.info('something went wrong saving the notification' + ex.message)
      end
      save_user_state(content_owner.handle, UserStateTypes::COMMENT_RECEIVE_DATE)
    end
    audience_handles.each do |comment_handle|
      Rails.cache.fetch("#{REDIS_KEYS::CACHE_SHOULD_SEND_COMMENT}-#{comment_handle}", expires_in: 2.hours) do
        Notifier.email_comment_audience(user_map[comment.poster_id], user_map[comment_handle], comment, content).deliver
        true
      end

      begin
        create_notification(comment_handle, comment.poster_id, content.id, MeedNotificationType::THREADED_COMMENT_STORY)
      rescue Exception => ex
        logger.info('something went wrong saving the notification' + ex.message)
      end
    end
  end
end