class Event
  include Mongoid::Document
  field :id, type: String
  field :title, type: String
  field :description, type: String
  field :type, type: String, default: 'ama'
  field :event_id, type: String
  field :start_dttm, type: Time
  field :end_dttm, type: Time
  field :create_dttm, type: Time, default: Time.now
  field :major_type_ids, type: Array
  field :schools, type: Array
  field :collection_ids, type: Array, default: []
  field :company_id, type: String
  field :author_id, type: String
  field :author_picture, type: String
  field :marketing_picture, type: String
  field :facebook_event_url, type: String
  field :followers, type: Array, default: []

  attr_accessible :id,
                  :title,
                  :description,
                  :event_id,
                  :type,
                  :start_dttm,
                  :end_dttm,
                  :create_dttm,
                  :major_type_ids,
                  :company_id,
                  :collection_ids,
                  :author_id,
                  :marketing_picture,
                  :facebook_event_url,
                  :followers, type: Array, default: []

end