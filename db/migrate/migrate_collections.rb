feed_items = FeedItems.where(:collection_ids.exists => true)
feed_items.each do |feed_item|
  collection_ids = feed_item.collection_ids
  unless collection_ids.blank?
    collection_ids.each do |collection_id|
      if collection_id.blank?
        next
      end
      collection = Collection.find(collection_id)
      if collection.blank?
        next
      end
      unless collection.handle.eql? feed_item.poster_id
        collection.add_to_set(:contributors, feed_item.poster_id)
        follow_collection(feed_item.poster_id, collection_id)
      end
      collection.save
    end
  end

end