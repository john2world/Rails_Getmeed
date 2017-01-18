class SyllabusQuestions
  include Mongoid::Document
  field :_id, type: String, default: -> { syllabus_id }
  field :syllabus_id, type: String
  field :question_ids, type: Array
  attr_accessible :syllabus_id, :question_ids
end