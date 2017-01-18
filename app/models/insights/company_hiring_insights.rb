class CompanyHiringInsights
  include Mongoid::Document
  field :_id, type: String, default: -> { school_id+"_"+company_id+"_"+year.to_s }
  field :school_id, type: String
  field :company_id, type: String
  field :year, type: Integer
  field :major_counts, type: Array
  field :skill_counts, type: Array

  attr_accessible :school_id, :company_id, :year, :major_counts, :skills_count
end