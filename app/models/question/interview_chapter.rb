class InterviewChapter
  include Mongoid::Document
  field :_id, type: String, default: -> { chapter_num }
  field :chapter_num, type: String
  field :name, type: String
  field :major_code, type: String
  attr_accessible :chapter_num, :name, :major_code
end