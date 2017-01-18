class MeedFriend
  include Mongoid::Document
  field :handle, type: String
  field :friend_handle, type: String

  attr_accessible :handle,
                  :friend_handle
end