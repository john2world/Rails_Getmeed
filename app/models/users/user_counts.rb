class UserCounts
  include Mongoid::Document
  field :handle, type: String
  field :notification_count, type: Integer, default: 0
  field :meed_points, type: Integer


  attr_accessible :handle, :notification_count, :meed_points

end