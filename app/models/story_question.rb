class StoryQuestion
  include Mongoid::Document

  field :title
  field :type
  field :placeholder
  field :required, type: Boolean, default: false
end
