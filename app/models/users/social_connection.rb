class SocialConnection
  include Mongoid::Document
  field :connected_handle, type: String
  field :location_name, type: String
  field :country, type: String
  field :first_name, type: String
  field :last_name, type: String
  field :industry, type: String
  field :picture_url, type: String
  field :headline, type: String
  field :social_network, type: String, default: 'linkedin'
  field :create_dttm, type: Date, default: Time.zone.now

  attr_accessible :first_name,
                  :last_name,
                  :country,
                  :location_name,
                  :social_network,
                  :headline,
                  :create_dttm,
                  :picture_url

end