class UserMessages
  include Mongoid::Document
  include LinkHelper
  field :_id, type: String, default: -> { handle }
  field :handle, type: String
  field :message_ids, type: Array

  attr_accessible :handle, :message_ids

end