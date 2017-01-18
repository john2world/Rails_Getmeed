class MeedPointsTransaction
  include Mongoid::Document
  field :handle, type: String
  field :type, type: String
  field :create_dttm, type: Date, default: Time.now()
  field :points, type: Integer, default: -> { 0 }
  field :data, type: Hash, default: -> {}
  attr_accessible :handle, :type, :create_dttm, :points, :data
end