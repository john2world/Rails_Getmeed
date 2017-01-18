class UserFollow
  include Mongoid::Document
  field :_id, type: String, default: -> { user_handle }
  field :user_handle, type: String
  field :company_ids, type: Array, default: -> { [] }

  attr_accessible :user_handle, :company_ids
end