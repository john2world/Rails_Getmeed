class UserJobAppStats
  include Mongoid::Document
  field :_id, type: String
  field :job_id, type: String
  field :handle, type: String
  field :status, type: String
  field :user_status, type: String

  attr_accessible :_id, :job_id, :status, :handle, :user_status

  def self.default_user_status_list
    return ['applied', 'contacted', 'telephone', 'onsite', 'offered', 'accepted', 'rejected']
  end
end