class CreateFeedItemWorker
  include Sidekiq::Worker
  include FeedItemsManager

  sidekiq_options retry: true, :queue => :default

  def perform(handle, id, type, privacy)
    create_feed_item(handle, id, type, privacy)
  end
end