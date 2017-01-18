class UserSeenFeatures
  include Mongoid::Document
  field :handle, type: String
  field :seen_career_hub, type: Boolean

  attr_accessible :handle, :seen_career_hub
end
