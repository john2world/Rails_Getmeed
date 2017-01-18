class SocialChannels
  include Mongoid::Document

  field :school_handle, type: String
  field :name, type: String
  field :type, type: String
  field :link, type: String
  field :source, type: String
  field :views, type: Integer

  attr_accessible :school_handle, :name,
                  :type, :link, :source, :views

end