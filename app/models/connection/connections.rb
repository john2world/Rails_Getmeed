class Connections
  include Mongoid::Document
  field :_id, type: String, default: -> { handle }
  field :handle, type: String
  field :user_ids, type: Array


  attr_accessible :handle ,
                  :_id, :user_ids
end