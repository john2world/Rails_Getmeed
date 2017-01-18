class JobView
  include Mongoid::Document
  include LinkHelper
  field :_id, type: String, default: -> { job_id }
  field :job_id, type: String
  field :handle, type: String
  field :create_dttm, type: Date

  attr_accessible :_id, :job_id, :handle, :create_dttm
end