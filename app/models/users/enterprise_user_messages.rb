class EnterpriseUserMessages
  include Mongoid::Document
  field :_id, type: String, default: -> { handle }
  field :handle, type: String
  field :message_ids, type: Array

  attr_accessible :handle, :message_ids
end