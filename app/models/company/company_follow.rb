class CompanyFollow
  include Mongoid::Document
  field :company_id, type: String
  field :user_handle, type: String
  field :time, type: Date

  attr_accessible :company_id, :user_handle
end