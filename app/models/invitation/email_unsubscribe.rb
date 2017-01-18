class EmailUnsubscribe
  include Mongoid::Document
  field :_id, type: String, default: -> { email }
  field :email, type: String
  field :type, type: String
  field :time, type: Date

  attr_accessible :email, :type, :time
end