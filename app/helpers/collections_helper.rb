module CollectionsHelper

  def get_collection_metadata(collection, author)
    unless collection.blank? or author.blank?
      metadata = Hash.new
      metadata[:title] = "#{collection.title}"
      metadata[:description] = "Follow #{author.first_name}'s professional collection on Meed'"
      metadata[:image_url] = collection.large_image_url
      metadata[:url] = get_collection_slug_url(collection.id,collection.handle, collection.slug_id)
      metadata
    end
  end

  def get_tag_metadata(tag)
    metadata = Hash.new
    metadata[:title] = "#{tag.title}"
    metadata[:description] = "Meed submissions in the tag #{tag.title}"
    metadata[:url] = get_tag_url(tag.id)
    metadata
  end
end