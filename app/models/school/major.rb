class Major
  include Mongoid::Document
  field :_id, type: String, default: -> { code }
  field :code, type: String
  field :major, type: String
  field :major_type_id, type: String

  attr_accessible :_id, :code, :major, :major_type_id
end