class UserPromotion
  include Mongoid::Document
  field :_id, type: String, default: -> { "#{handle}_#{type}" }
  field :type, type: Array
  field :handle, type: String
  field :referrer, type: String
  field :create_dttm, type: Date, default: -> { Time.now }
  attr_accessible :handle, :type, :create_dttm

end