class InviteUsers
  include Mongoid::Document
  field :_id, type: String, default: -> { invitor_handle }
  field :invitor_handle, type: String
  field :invitee_emails, type: Array

  attr_accessible :invitor_handle, :invitee_emails

end