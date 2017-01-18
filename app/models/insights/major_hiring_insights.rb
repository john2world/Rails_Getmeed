class MajorHiringInsights
  include Mongoid::Document
  field :_id, type: String, default: -> { school_id+"_"+major_id+"_"+year.to_s }
  field :school_id, type: String
  field :major_id, type: String
  field :year, type: Integer
  field :company_counts, type: Hash
  field :skills_count, type: Hash

  attr_accessible :school_id, :major_id, :year, :major_counts, :skills_count
end