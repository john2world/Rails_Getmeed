class Article
  include Mongoid::Document
  include LinkHelper
  field :title, type: String
  field :url, type: String
  field :tag_line, type: String
  field :description, type: String
  field :view_count, type: Integer
  field :date, type: Date
  field :majors, type: Array
  field :schools, type: Array
  field :external_url, type: String
  field :source, type: String
  field :photo_id, type: String
  field :video_id, type: String
  field :majors, type: Array
  field :author, type: String
  field :author_url, type: String
  field :company_id, type: String
  field :html, type: String
  field :type, type: String

  attr_accessible :title, :url, :tag_line, :description, :view_count,
                  :date, :majors, :schools, :external_url, :author,
                  :author_url, :html, :photo_id, :company_id, :video_id,
                  :type

  set_callback(:save, :after, if: (:title_changed? || :description_changed?)) do |document|
    SitemapPingerWorker.perform_async(get_story_url(self.author, self.id))
  end

  def article_url
    get_story_url(self.author, self.id)
  end

end