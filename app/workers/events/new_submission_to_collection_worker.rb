class NewSubmissionToCollectionWorker
  include Sidekiq::Worker
  include UsersManager
  include CollectionsManager
  include CommentsManager
  include FeedItemsManager

  sidekiq_options retry: true, :queue => :default

  def perform(feed_id, collection_id)
    if collection_id.blank?
      return
    end
    collection = get_collection(collection_id)
    if collection.blank?
      return
    end
    feed_item = get_feed_item_for_id(feed_id)
    if feed_item.blank?
      return
    end
    collection.inc(:submission_count, 1)
    collection.last_submission_dttm = Time.now
    unless collection.handle.eql? feed_item.poster_id
      collection.add_to_set(:contributors, feed_item.poster_id)
      follow_collection(feed_item.poster_id, collection_id)
    end
    collection.save

    submittor = get_user_by_handle(feed_item.poster_id)
    save_user_state(submittor, UserStateTypes::LAST_SUBMISSION_DATE)
    
    if feed_item.portfolio
      save_user_state(submittor.handle, UserStateTypes::PORTFOLIO_SUBMISSION)
    end

    if submittor.handle.eql? collection.handle
      return
    end
    collection_owner = get_user_by_handle(collection.handle)
    if collection_owner.blank? or submittor.blank? or feed_item.blank?
      return
    end

    Rails.cache.delete_matched("#{REDIS_KEYS::CACHE_FEED_ITEM_USER_STORIES}*")
    Rails.cache.delete("#{REDIS_KEYS::CACHE_COLLECTION_FEED}-#{collection_id}")
    Rails.cache.delete("#{REDIS_KEYS::CACHE_COLLECTION_FEED_PTFLO}-#{collection_id}")
    unless feed_item.event_id.blank?
      influencer = get_user_by_handle(event.author_id)
      Rails.cache.fetch("#{REDIS_KEYS::CACHE_SHOULD_SEND_QUESTION}-#{influencer.handle}", expires_in: 24.hours) do
        event = get_events(feed_item.event_id)
        unless event.blank?
          unless influencer.blank?
            Notifier.email_influencer_question_submission(influencer, submittor, feed_item).deliver
          end
        end
        true
      end
    end

    # unless collection.handle.eql? feed_item.poster_id
      # Notifier.email_collection_owner_submission( collection_owner, submittor, collection, feed_item).deliver
    # end
  end

end