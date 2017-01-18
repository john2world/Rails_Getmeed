class ProfileImpressions
  include Mongoid::Document
  include LinkHelper

  field :_id, type: String, default: -> { handle }
  field :handle, type: String
  field :viewers, type: Array
  field :job_ids, type: Array
  field :company_ids, type: Array
  field :public_view_count, type: Integer
  field :total_view_count, type: Integer
  field :last_view_dttm, type: Date

  attr_accessible :handle, :viewers, :public_view_count, :total_view_count
end