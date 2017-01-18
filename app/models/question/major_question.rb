class MajorQuestion
  include Mongoid::Document
  field :_id, type: String, default: -> { major }
  field :major, type: String
  field :question_id, type: String

  attr_accessible :_id, :question_id, :major
end