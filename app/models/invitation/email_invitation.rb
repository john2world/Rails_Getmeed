class EmailInvitation
  include Mongoid::Document
  field :email, type: String
  field :activated, type: Boolean
  field :invitor_handle, type: String
  field :time, type: Date
  field :reminder_count, type: Integer, default: 0
  field :last_variation_used, type: String
  field :token, type: String

  attr_accessible :email, :activated, :invitor_handle, :time, :last_variation_used, :reminder_count

end