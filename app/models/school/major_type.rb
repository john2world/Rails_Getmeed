  class MajorType
  include Mongoid::Document
  field :_id, type: String, default: -> { major_type_id }
  field :major_type_id, type: String
  field :major_ids, type: Array
  field :industry_ids, type: Array
  field :name, type: String
  field :broad_classification, type: String

  attr_accessible :_id, :major_type_id, :name, :major_ids, :broad_classification, :industry_ids
end