class MeedioriteInvitation
  include Mongoid::Document
  field :activated, type: Boolean
  field :invitor_handle, type: String
  field :create_dttm, type: Time.now
  field :token, type: String

  attr_accessible :activated, :invitor_handle, :create_dttm, :token

end