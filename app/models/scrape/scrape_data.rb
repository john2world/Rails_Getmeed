class ScrapeData
  include Mongoid::Document
  field :_id, type: String
  field :title, type: String
  field :description, type: String
  field :full_description, type: String
  field :large_image_url, type: String
  field :medium_image_url, type: String
  field :small_image_url, type: String
  field :video_id, type: String
  field :author_name, type: String
  field :source_url, type: String
  field :company_id, type: String
  field :user_handle, type: String
  field :poster_logo, type: String
  field :type, type: String
  field :source_type, type: String
  field :tags, type: Array
  field :create_date, type: Date
  field :metadata_url, type: String
  field :file_url, type: String
  field :url, type: String
  attr_accessible :_id, :large_image_url, :small_image_url,
                  :url, :title, :medium_image_url,
                  :description, :full_description, :tags,
                  :user_handle,
                  :source_url, :author_name, :type,
                  :source_type, :poster_logo, :video_id,
                  :create_date, :company_id, :file_url, :metadata_url

end