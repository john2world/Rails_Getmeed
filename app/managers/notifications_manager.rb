module NotificationsManager
  # returns true if the email is not marked as unsubscribed
  def check_email_unsubscribed(email)
    return EmailUnsubscribe.find(email).blank?
  end

  def get_notifications_for_user(user_id)
    notif_cache = Rails.cache.fetch("#{REDIS_KEYS::CACHE_NOTIFICATIONS}-#{user_id}") do
      ConsumerNotification.where(:handle => user_id).order_by([:last_update_dttm, -1]).to_a
    end
    notif_cache
  end

  def get_notification_count_for_user(handle)
    ret = Rails.cache.fetch("#{REDIS_KEYS::CACHE_NOTIFICATION_COUNT}-#{handle}") do
      user_counts = UserCounts.find(handle)
      if user_counts.blank?
        user_counts = UserCounts.new
        user_counts.id = handle
        user_counts.notification_count = 0
        user_counts.save
      end
      user_counts.notification_count
    end
    ret
  end

  def set_notification_counts(handle, count)
    Rails.cache.delete("#{REDIS_KEYS::CACHE_NOTIFICATION_COUNT}-#{handle}")
    user_counts = UserCounts.find(handle)
    if user_counts.blank?
      user_counts = UserCounts.new
      user_counts.id = handle
    end
    user_counts.notification_count = count
    user_counts.save
    user_counts
  end

  def increment_notification_count(handle)
    Rails.cache.delete("#{REDIS_KEYS::CACHE_NOTIFICATION_COUNT}-#{handle}")
    user_counts = UserCounts.find(handle)
    if user_counts.blank?
      user_counts = UserCounts.new
      user_counts.id = handle
      user_counts.notification_count = 0
    end
    user_counts.notification_count += 1
    user_counts.save
    user_counts
  end

  def create_notification(handle, from_handle, subject_id, notification_type, create_dttm = nil)
    Rails.cache.delete("#{REDIS_KEYS::CACHE_NOTIFICATIONS}-#{handle}")
    if handle.eql? from_handle
      return
    end

    if handle.blank? or from_handle.blank?
      return
    end

    unless notification_type.blank?
      notification = ConsumerNotification.find("#{handle}_#{subject_id}_#{notification_type}")
      if notification.blank?
        notification = ConsumerNotification.new
        notification.id = "#{handle}_#{subject_id}"
        notification.handle = handle
        notification.subject_id = subject_id
        notification.notification_type = notification_type.to_s
      end
      notification.add_to_set(:from_handles, from_handle)
      if create_dttm.blank?
        notification.last_update_dttm = Time.now
      else
        notification.last_update_dttm = create_dttm
      end
      notification.save
      increment_notification_count(handle)
    end
  end

  def build_notification_models(notifications)
    user_handles = Array.new
    content_subject_ids = Array.new
    notification_models = Array.new

    notifications.each do |notification|
      user_handles << notification.handle
      user_handles.concat notification.from_handles
      meed_notification_type = MeedNotificationType.const_get(notification.notification_type.upcase)
      if meed_notification_type.eql? MeedNotificationType::UPVOTE_STORY
        upvote = get_user_kudos(notification.subject_id)
        if upvote.blank?
          next
        end
        content_subject_ids << upvote.subject_id
      end
    end

    user_map = get_users_map_handles(user_handles)
    notifications.each do |notification|
      names = []
      image_url = ''
      notification.from_handles.each do |handle|
        user = user_map[handle]
        unless user.blank?
          names << user.first_name
          image_url = user.small_image_url
        end
      end
      if names.blank?
        next
      end
      notification[:names] = names
      notification.image_url = image_url
      case MeedNotificationType.const_get(notification.notification_type.upcase)
        when MeedNotificationType::UPVOTE_STORY
          notification[:notification_url] = get_perma_url(notification.subject_id)
          notification[:caption] = 'upvoted your post'
        when MeedNotificationType::COMMENT_STORY
          notification[:notification_url] = get_perma_url(notification.subject_id)
          notification[:caption] = 'commented on your post'
        when MeedNotificationType::FOLLOW_COLLECTION
          notification[:notification_url] = get_collection_url(notification.subject_id)
          notification[:caption] = 'joined your community!'
        when MeedNotificationType::FOLLOW_USER
          notification[:notification_url] = get_user_profile_url(notification.handle)
          notification[:caption] = 'started following you!'
        when MeedNotificationType::THREADED_COMMENT_STORY
          notification[:notification_url] = get_perma_url(notification.subject_id)
          notification[:caption] = 'also commented on a post you follow!'
        when MeedNotificationType::UPVOTE_COMMENT
          notification[:notification_url] = get_perma_url(notification.subject_id)
          notification[:caption] = 'upvoted your comment!'
        when MeedNotificationType::FRIEND_JOINED
          notification[:notification_url] = get_user_profile_url(notification.subject_id)
          notification[:caption] = 'joined Meed!'
        else
      end
      notification_models << notification
    end
    notification_models
  end
end