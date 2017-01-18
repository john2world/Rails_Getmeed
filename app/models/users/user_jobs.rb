class UserJobs
  include Mongoid::Document
  include LinkHelper

  field :_id, type: String, default: -> { user_job_id }
  field :user_job_id, type: String
  field :job_ids, type: Array

  attr_accessible :user_job_id, :job_ids

end
