class Industry
  include Mongoid::Document
  field :_id, type: String, default: -> { industry_id }
  field :industry_id, type: String
  field :major_type_ids, type: Array
  field :name, type: String

  attr_accessible :_id, :industry_id, :name, :major_type_ids
end