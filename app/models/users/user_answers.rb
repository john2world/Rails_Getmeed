class UserAnswers
  include Mongoid::Document
  field :_id, type: String, default: -> { handle }
  field :handle, type: String
  field :comment_ids, type: Array
  attr_accessible :handle, :comment_ids
end