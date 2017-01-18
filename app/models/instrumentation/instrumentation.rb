class Instrumentation
  include Mongoid::Document
  field :event_name, type: String
  field :event_start, type: DateTime
  field :event_end, type: DateTime
  field :event_id, type: String
  field :event_payload, type: Hash

  attr_accessible :event_name, :event_start, :event_end, :event_id, :event_payload
end