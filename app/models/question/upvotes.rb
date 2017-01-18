class Upvotes
  include Mongoid::Document
  field :_id, type: String, default: -> { comment_id }
  field :comment_id, type: String
  field :handles, type: Array
  attr_accessible :comment_id, :handles
end