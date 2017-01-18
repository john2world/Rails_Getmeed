class Tag
  include Mongoid::Document
  include LinkHelper
  field :title, type: String
  field :tag_count, type: Integer, default: 0
  field :view_count, type: Integer, default: 0
  field :last_updated_dttm, type: Date, default: Time.now
  field :default, type: Boolean, default: false
  field :icon, type: String, default: 'tag'
  attr_accessible :title,
                  :tag_count,
                  :view_count,
                  :last_updated_dttm,
                  :default,
                  :icon

  def tag_url
    get_tag_url(_id)
  end

end
