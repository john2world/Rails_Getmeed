class UserFollowCollection
  include Mongoid::Document
  include LinkHelper
  field :id, type: String
  field :follower_id, type: String
  field :collection_id, type: String
  field :create_dttm, type: DateTime, default: Time.now

  attr_accessible :id, :follower_id, :create_dttm, :collection_id


end