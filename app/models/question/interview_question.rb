class InterviewQuestion
  include Mongoid::Document
  field :_id, type: String
  field :title, type: String
  field :description, type: String
  field :tags, type: String
  field :chapter, type: String
  attr_accessible :_id, :title, :description, :tags, :chapter
end