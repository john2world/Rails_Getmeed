class EmailFollowCollectionWorker
  include Sidekiq::Worker
  include UsersManager
  include CollectionsManager
  include NotificationsManager
  include FeedItemsManager
  def perform(handle, collection_id)
    if handle.blank? or collection_id.blank?
      return
    end

    follower = get_user_by_handle(handle)
    save_user_after_checks(follower)
    collection = get_collection(collection_id)
    if follower.blank? or collection.blank?
      return
    end
    collection_owner = get_user_by_handle(collection.handle)
    if collection_owner.blank?
      return
    end
    Rails.cache.delete_matched("#{REDIS_KEYS::CACHE_SCHOOL_COLLECTIONS_ID}*")
    Rails.cache.delete_matched("#{REDIS_KEYS::CACHE_USER_FOLLOW_COLLECTIONS}-#{handle}")
    collection_owner[:meed_points] = get_user_meed_points(collection.handle)
    # Notifier.email_collection_owner_follow(collection_owner, follower, collection).deliver
    # create_notification(collection_owner.handle, follower.handle, collection.id, get_notification_type_for_feed(UserFeedTypes::FOLLOW_COLLECTION))
    save_user_state(collection_owner.handle, UserStateTypes::FOLLOWER_RECEIVE_DATE)
    save_user_state(follower.handle, UserStateTypes::FOLLOW_COLLECTION_DATE)
  end

end