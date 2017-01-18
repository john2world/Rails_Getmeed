module KudosManager
  include NotificationsManager
  include NotificationsHelper

  def give_kudos_from_feed(handle, feed_id)
    feed_item = FeedItems.find(feed_id)
    if feed_item.blank?
      return
    end
    user_kudos = Kudos.where(:feed_id => feed_id, :giver_handle => handle)
    if user_kudos.blank?
      user_kudos = Kudos.new
      user_kudos.handle = feed_item.poster_id
      user_kudos.giver_handle = handle
      user_kudos.feed_id = feed_id
      user_kudos.subject_id = feed_item.subject_id
      user_kudos.subject_type = feed_item[:type]
      user_kudos.create_dttm = Time.zone.now
      user_kudos.save
    else
      # don't do anything
      return
    end

    unless feed_item.blank?
      begin
        increment_feed_kudos_count(feed_item.id, handle)
        unless is_feed_media_type(feed_item[:type].upcase)
          increment_profile_kudos(feed_item.subject_id, UserFeedTypes.const_get(feed_item[:type].upcase))
        end
      rescue Exception => ex
        $log.error "Something wrong in giving kudos: #{ex}"
      end
      unless user_kudos.handle.eql? user_kudos.giver_handle
        if Rails.env.development?
          test_kudos_email(user_kudos.id.to_s)
        end
          EmailKudosWorker.perform_async(user_kudos[:_id].to_s)
      end
    end

  end

  def get_user_kudos(id)
    Kudos.find(id)
  end

  def give_kudos_for_subject_id(handle, subject_id)
    feed_item = FeedItems.find_by(subject_id: subject_id)
    if feed_item.blank?
      return
    end
    user_kudos = Kudos.where(:feed_id => feed_item.id, :giver_handle => handle)
    if user_kudos.blank?
      user_kudos = Kudos.new
      user_kudos.handle = feed_item.poster_id
      user_kudos.giver_handle = handle
      user_kudos.feed_id = feed_item.id
      user_kudos.subject_id = feed_item.subject_id
      user_kudos.subject_type = feed_item[:type]
      user_kudos.create_dttm = Time.zone.now
      user_kudos.save
    else
      # don't do anything
      return
    end

    unless feed_item.blank?
      begin
        increment_feed_kudos_count(feed_item.id, handle)
        unless is_feed_media_type(feed_item[:type].upcase)
          increment_profile_kudos(feed_item.subject_id, UserFeedTypes.const_get(feed_item[:type].upcase))
        end
      rescue Exception => ex
        $log.error "Something wrong in giving kudos: #{ex}"
      end
      unless user_kudos.handle.eql? user_kudos.giver_handle
        if Rails.env.development?
          test_kudos_email(user_kudos.id.to_s)
        end
        EmailKudosWorker.perform_async(user_kudos[:_id].to_s)
      end
    end
    feed_item
  end

  def get_kudos_giver_map_feed_ids(handle, feed_ids)
    if feed_ids.blank?
      return
    end
    kudos_map = Hash.new
    kudos = Kudos.where(:giver_handle => handle, :feed_id.in => feed_ids)
    kudos.each do |kudo|
      kudos_map[kudo.feed_id] = kudo
    end
    kudos_map
  end

  def get_kudos_giver_map_subject_ids(handle, subject_ids)
    if subject_ids.blank?
      return
    end
    kudos_map = Hash.new
    kudos = Kudos.where(:giver_handle => handle, :subject_id.in => subject_ids)
    kudos.each do |kudo|
      kudos_map[kudo.subject_id] = kudo
    end
    kudos_map
  end

  def get_kudos_by_handle(handle)
    Kudos.where(:giver_handle => handle)
  end

  def test_kudos_email(kudos_id)
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
    feed_item = get_feed_item_for_id(user_kudos.feed_id)

    if user.blank? and giver_user.blank?
      return
    end
    Rails.cache.delete_matched("#{REDIS_KEYS::CACHE_FEED_ITEM_USER_STORIES}*")
    create_notification(user.handle, giver_user.handle, user_kudos.feed_id, get_notification_type_for_feed(user_kudos[:subject_type]))
    Notifier.email_kudos(giver_user, user, user_kudos[:subject_type], false,feed_item).deliver
  end

end