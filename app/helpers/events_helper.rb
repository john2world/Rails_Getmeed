module EventsHelper
  def get_ama_metadata(ama, author)
    if ama.blank? || author.blank?
      return nil
    end
    metadata = Hash.new
    metadata[:title] = "AMA with #{author.name}"
    metadata[:description] = "#{ama.title}. Ask Me Anything!"
    image_url = ama.marketing_picture.blank?? ama.author_picture : ama.marketing_picture
    metadata[:image_url] = image_url
    metadata[:url] = url_for(controller: "events", action: "show_ama", ama_id: ama.id)
    metadata
  end

  def get_ama_id_from_url(url)
    if !url.include? "/ama/"
      return nil
    end
    path = URI.parse(url).path
    if path.blank?
      return nil
    end
    match = /\/ama\/([^\/]*)/.match(path)
    if match.blank? || match.captures.blank?
      return nil
    end
    return match.captures[0]
  end
end