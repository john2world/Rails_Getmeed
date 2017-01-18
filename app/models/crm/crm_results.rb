class CrmResults
  include Mongoid::Document
  field :_id, type: String, default: -> { ab_id }
  field :ab_id, type: String
  field :clicks, type: Integer
  field :conversions, type:Integer
  field :send_count, type: Integer
  field :update_dttm, type: Date, default: Time.zone.now

  attr_accessible :ab_id,
                  :clicks,
                  :conversions,
                  :update_dttm
end