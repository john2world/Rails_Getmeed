class EmailMeedPostWorker
  include Sidekiq::Worker
  include FeedItemsManager
  include UsersManager
  include SchoolsManager

  sidekiq_options retry: true, :queue => :default


  def perform(feed_id)
    if feed_id.blank?
      return
    end

    data = get_feed_item_for_id(feed_id)
    if data.blank?
      return
    end

    poster = get_user_by_handle(data.poster_id)
    if poster.blank?
      return
    end

    # Notifier.email_meed_post_success(poster, data).deliver
  end
end