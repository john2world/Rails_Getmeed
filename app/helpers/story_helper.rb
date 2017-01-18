module StoryHelper
  include LinkHelper


  def get_story_metadata (feed_item)
    unless feed_item.blank?
      title = feed_item.title
      unless feed_item[:caption].blank?
        title = feed_item[:caption]
      end

      metadata = Hash.new
      metadata[:title] = "#{title}"
      metadata[:description] = feed_item.description
      unless feed_item[:large_image_url].blank?
        metadata[:image_url] = feed_item[:large_image_url]
      end
      metadata[:url] = get_story_url(feed_item.poster_id, feed_item.subject_id)
      metadata
    end
  end
end