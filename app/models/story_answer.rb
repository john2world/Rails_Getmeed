class StoryAnswer
  include Mongoid::Document

  field :content
  belongs_to :question, class_name: "StoryQuestion"
  embedded_in :story
end
