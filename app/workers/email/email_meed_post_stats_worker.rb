class EmailMeedPostStatsWorker
  include Sidekiq::Worker
  include FeedItemsManager
  include ProfilesManager
  include UsersManager

  sidekiq_options retry: true, :queue => :default

  def perform(id)
    user = get_user_by_handle(id)
    if user.blank?
      logger.info("Skipping weekly meed post stats to #{id} due to user being blank")
      return
    end

    user_feed_items = get_user_meed_posts(user.handle)
    popular_feed_items = get_popular_meed_posts(7.days.ago)

    if popular_feed_items.blank?
      logger.info("Skipping weekly meed post stats to #{id} due to empty popular feed_items")
      return
    end

    logger.info("Sending weekly meed post stats to #{id}")
    Notifier.email_meed_post_stats(user, popular_feed_items, user_feed_items).deliver
  end

end