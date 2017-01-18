class EmailKudosWorker
  include Sidekiq::Worker
  include KudosManager
  include UsersManager
  include FeedItemsManager
  include CommentsManager
  include NotificationsManager
  include NotificationsHelper
  sidekiq_options retry: true, :queue => :default


  def perform(kudos_id)
    user_kudos = Kudos.find(Moped::BSON::ObjectId(kudos_id))
    if user_kudos.blank?
      logger.info("kudos not found. Not sending email for #{kudos_id}")
      return
    end
    handles = Array.new
    handles << user_kudos[:giver_handle]
    handles << user_kudos[:handle]
    user_map = get_users_map_handles(handles)
    user = user_map[user_kudos[:handle]]
    giver_user = user_map[user_kudos[:giver_handle]]

    if user.blank? or giver_user.blank?
      return
    end
    feed_item = get_feed_item_for_id(user_kudos.feed_id)
    # send notification only if user setting is Every. else it will go as part of the digest.
    # if it is a enterprise send
    create_notification(user.handle, giver_user.handle, user_kudos.feed_id, get_notification_type_for_feed(user_kudos[:subject_type]))
    save_user_state(user.handle, UserStateTypes::UPVOTE_RECEIVE_DATE)
    Rails.cache.delete_matched("#{REDIS_KEYS::CACHE_FEED_ITEM_USER_STORIES}*")
    Rails.cache.fetch("#{REDIS_KEYS::CACHE_SHOULD_SEND_KUDOS}-#{user.handle}", expires_in: 2.hours) do
      Notifier.email_kudos(giver_user, user, user_kudos[:subject_type], false, feed_item).deliver
      true
    end
  end
end