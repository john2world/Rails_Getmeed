class GenerateCollectionTagsWorker
  include Sidekiq::Worker
  include CollectionsManager
  include FeedItemsManager
  include CommentsManager
  sidekiq_options retry: true, :queue => :default

  def perform(collection_id)
    # get all the posts in a collection
    if collection_id.blank?
      return
    end
    posts = get_feed_items_for_collection_id(collection_id)
    # get tags for posts
    tags = posts.map{|post| post.tags}.compact
    final_tags = {}
    tags.each do |t|
      final_tags = Hash[t].merge(final_tags){|key, first, second| first+second}
    end
    # normalizing the values
    sum = final_tags.values.sum()
    final_tags.each do |key, value|
      final_tags[key] = value/sum
    end
    save_collection_tags(collection_id, final_tags)
  end
end