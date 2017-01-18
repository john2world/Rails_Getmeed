class UserAppliedJobs
  include Mongoid::Document
  field :_id, type: String, default: -> { handle }
  field :handle, type: String
  field :job_ids, type: Array

  attr_accessible :handle, :job_ids
end
