class FeedItemService
  class FIManager;include FeedItemsManager;end;

  def self.increment_feed_view_count subject_id
    FIManager.new.increment_feed_view_count subject_id
  end
end
