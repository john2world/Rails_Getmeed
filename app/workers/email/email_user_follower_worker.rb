class EmailUserFollowerWorker
  include Sidekiq::Worker
  include UsersManager
  include CrmManager
  include EventsManager
  include NotificationsManager
  include MeedPointsTransactionManager

  sidekiq_options :retry => 5, :queue => :default

  def perform(follow_id)
    follow_user = UserFollowUser.find(follow_id)
    if follow_user.blank?
      return
    end
    follower = get_user_by_handle(follow_user.follower_handle)
    user = get_user_by_handle(follow_user.handle)
    ama = get_ama_by_handle(follow_user.handle)
    unless ama.start_dttm.blank?
      if ama.start_dttm > Time.now
        EmailAmaFollowWorker.perform_async(ama.author_id, follow_user.handle)
      end
    end

    create_notification(follow_user.handle, follow_user.follower_handle, follow_user.handle, MeedNotificationType::FOLLOW_USER)
    reward_for_user_follower(user.handle, follower.handle)
    Rails.cache.delete("#{REDIS_KEYS::CACHE_USER_FOLLOWER_IDS}-#{user.handle}")
    Rails.cache.delete("#{REDIS_KEYS::CACHE_USER_FOLLOWEE_IDS}-#{follower.handle}")

    Rails.cache.delete("#{REDIS_KEYS::CACHE_USER_RECOMMENDATION_IDS }-#{follower.handle}")
    Rails.cache.fetch("#{REDIS_KEYS::CACHE_SHOULD_SEND_FOLLOWER}-#{user.handle}", expires_in: 24.hours) do
      Notifier.email_user_follow(user, follower).deliver
      true
    end
    true
  end
end