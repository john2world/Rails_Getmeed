class WaitListInvitation
  include Mongoid::Document
  field :_id, type: String, default: -> { handle }
  field :handle, type: String
  field :email_ids, type: Array

  attr_accessible :_id, :handle, :email_ids
end