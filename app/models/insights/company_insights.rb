class CompanyInsights
  include Mongoid::Document
  field :_id, type: String, default: -> { company_id }
  field :company_id, type: String
  field :ratings, type: Array
  field :reviews, type: Array
  field :salary, type: Array
  field :benefits, type: Hash
  field :interview, type: Hash
  field :sources, type: Array

  attr_accessible :company_id, :ratings, :reviews, :salary, :benefits, :interview, :sources
end