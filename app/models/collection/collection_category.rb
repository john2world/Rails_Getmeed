class CollectionCategory
  include Mongoid::Document
  include LinkHelper
  field :title, type: String
  field :small_image_url, type: String
  field :medium_image_url, type: String
  field :large_image_url, type: String
  field :collection_count, type: Integer, default: 0
  field :privacy, type: String, default: -> { 'everyone' }

  attr_accessible :title,
                  :small_image_url,
                  :medium_image_url,
                  :large_image_url,
                  :small_image_url,
                  :collection_count,
                  :privacy

end