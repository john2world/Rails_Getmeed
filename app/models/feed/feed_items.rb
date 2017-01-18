class FeedItems
  include Mongoid::Document
  include LinkHelper
  searchkick
  #merge_mappins: true, mappings: { feed_items: {_ttl: {enabled: true, default: '180d'}}}

  field :title, type: String
  field :tag_line, type: String
  field :subject_id, type: String
  field :privacy, type: String
  field :privacies, type: Array
  field :major_types, type: Array
  field :privacy_text, type: String
  field :public_post, type: Boolean, default: true
  field :scrape_id, type: String
  field :small_image_url, type: String
  field :medium_image_url, type: String
  field :large_image_url, type: String
  field :url, type: String
  field :create_time, type: DateTime, default: Time.now
  field :internal_id, type: String
  field :type, type: String
  field :portfolio, type: Boolean, default: false
  field :caption, type: String
  field :description, type: String
  field :video_id, type: String
  field :job_ids, type: Array
  field :video_type, type: String
  field :tags, type: Array
  field :tag_ids, type: Array, default: -> { Array.new }
  field :collections, type: Array
  field :event_id, type: String
  field :add_to_profile, type: Boolean
  field :comment_count, type: Integer, default: 0
  field :kudos_count, type: Integer, default: 0
  field :view_count, type: Integer, default: 0
  field :poster_id, type: String
  field :poster_type, type: String
  field :poster_school, type: String
  field :collection_ids, type: Array, default: -> { [ collection_id ] }
  field :collection_id, type: String
  field :poster_logo, type: String
  field :external_url, type: String
  field :photo_id, type: String
  field :is_anonymous, type: Boolean
  field :embed_code, type: String
  field :skills, type: Array
  field :feed_rank, type: Integer, default: 0
  field :last_updated, type: DateTime, default: Time.now
  alias_method :poster_handle, :poster_id

  attr_accessible :title, :tag_line,
                  :small_image_url,
                  :add_to_profile,
                  :public_post,
                  :skills,
                  :event_id,
                  :privacies,
                  :create_time, :internal_id,
                  :type, :url,
                  :description, :subject_id,
                  :kudos_count,
                  :comment_count,
                  :major_types,
                  :view_count, :poster_id,
                  :poster_type,
                  :medium_image_url,
                  :large_image_url,
                  :small_image_url,
                  :poster_school,
                  :job_ids,
                  :collection_id,
                  :collection_ids,
                  :photo_id,
                  :tag_ids,
                  :path,
                  :poster_logo, :caption,
                  :external_url, :is_anonymous,
                  :feed_rank, :tags, :collections

  def poster_object
    @poster_object ||= self.poster_type.classify.constantize.find_by handle: self.poster_handle
  end

  def comment_objects
    @comment_objects ||= Comment.where(feed_id: self.id)
  end

  def collection_object
    @collection_object ||= Collection.where(:id.in => self.collection_ids).first
  end

  # limiting indexing to following fields
  def search_data
    as_json only: [:title, :tag_line, :type, :description, :caption, :create_time, :privacy, :poster_school,
                   :poster_type, :tags, :tag_ids, :portfolio, :collection_ids, :view_count, :large_image_url, :subject_id, :privacies]
  end


  def should_index?
    return !(poster_id.blank? || poster_type.blank?) &
        (type.in? ['internship', 'userwork', 'story', 'user_course_review']) &
        (!create_time.blank?) & (create_time > 6.months.ago)
  end

  def story_url
    get_story_url(poster_id, subject_id, create_time)
  end

  def as_json(options={})
    options[:except] ||= [:major_types, :job_ids, :internal_id, :skills, :privacies, :tag_ids, :collection_ids,:tags, :privacy, :poster_school]
    super(options).reject { |k, v| v.nil? }
  end

end
