class UserDownvote
  include Mongoid::Document
  belongs_to :user
  has_and_belongs_to_many :feed_items, class_name: "FeedItems"

  def self.from_user user
    first_or_create user: user
  end

  def downvote feed_item, by = 2.days
    if downvoted? feed_item
      false
    else
      feed_item.update_attribute :last_updated, feed_item.last_updated - by
      self.feed_items << feed_item
      self.save
    end
  end

  def downvoted? feed_item
    feed_item.in? self.feed_items
  end
end
