class UserGeneratedPosts
  include Mongoid::Document
  field :caption, type: String
  field :title, type: String
  field :description, type: String
  field :scrape_id, type: String
  field :privacy, type: String
  field :privacies, type: Array
  field :skills, type: Array
  field :url, type: String
  field :create_time, type: DateTime, default: -> { Time.zone.now }
  field :type, type: String
  field :poster_type, type: String
  field :poster_id, type: String
  field :poster_school, type: String
  field :photo_url, type: String
  field :photo_id, type: String
  field :embed_code, type: String
  field :is_anonymous, type: Boolean
  field :job_ids, type: Array
  field :tags, type: Array
  field :collections, type: Array
  field :featured, type: Boolean
  field :view_count, type: Integer, default: -> { 0 }

  attr_accessible :create_time,
                  :privacies,
                  :type, :url,
                  :description,
                  :title,
                  :tags,
                  :collections,
                  :poster_type,
                  :poster_id,
                  :poster_school,
                  :photo_url,
                  :photo_id,
                  :job_ids,
                  :is_anonymous,
                  :featured,
                  :view_count


end