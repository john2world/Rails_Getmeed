class CodeType
  include Mongoid::Document
  field :_id, type: String
  field :display_id, type: String
  field :file_ext, type: String
  field :major_code, type: String

  attr_accessible :display_id, :file_ext, :major_code
end