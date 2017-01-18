class Photo
  include Mongoid::Document
  field :large_image_url, type: String
  field :medium_image_url, type: String
  field :square_image_url, type: String
  field :subject_id, type: String
  field :type, type: String

  attr_accessible :large_image_url, :medium_image_url, :square_image_url,
                  :subject_id, :type

  def other_image_urls
    image_urls = Array.new
    image_urls << medium_image_url
    image_urls << square_image_url
    image_urls
  end

end