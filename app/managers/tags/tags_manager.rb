module TagsManager
  include CommonHelper
  def get_all_tags
    Tag.all.to_a
  end

  def get_current_trending_tags(limit)
    Tag.where(:_id.ne => 'portfolio').order_by([:view_count, -1]).limit(limit).to_a
  end

  def create_tag(title, default=false, icon = 'tag')
    id = generate_id_from_text(title)
    if id.blank?
      return nil
    end
    tag = Tag.find(id)
    if tag.blank?
      tag = Tag.new
      tag.id = id
      tag.title = capitalize_delimited_text(id)
      tag.default = default
      tag.icon = icon
      tag.save
    end
    tag
  end

  def get_or_create_tags(ids)
    tags = Tag.find(ids)
    map = Hash.new
    tags.each do |tag|
      map[tag.id] = tag
    end
    ids.each do |id|
      tag = map[id]
      increment_tag_view_count(id)
      if tag.blank?
        tag = create_tag(id)
        tags << tag
      end
    end
    tags
  end

  def get_tag(id)
    Tag.find(id)
  end

  def increment_tag_view_count(tag_id)
    Tag.where(_id: tag_id).inc(:view_count, 1)
  end

  def get_tag_map(ids)
    tags = Tag.find(ids)
    tag_map = Hash.new
    tags.each do |tag|
      tag_map[tag.id] = tag
    end
    tag_map
  end

end