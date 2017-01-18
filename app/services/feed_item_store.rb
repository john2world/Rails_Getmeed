class FeedItemStore
  def self.create_feed_item handle, subject_id, type, privacy, params = {}
    CourseReview.new.create_feed_item handle, subject_id, type, privacy, params
  end
end
