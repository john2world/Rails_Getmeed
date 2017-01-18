class Syllabus
  include Mongoid::Document
  field :_id, type: String
  field :display_id, type: String
  field :name, type: String
  field :major_code, type: String

  attr_accessible :display_id, :name, :major_code
end