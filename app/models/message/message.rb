class Message
  include Mongoid::Document
  include LinkHelper
  field :email, type: String
  field :handle, type: String
  field :subject, type: String
  field :body, type: String
  field :from_email, type: String
  field :status, type: String
  field :posted_dttm, type: DateTime


  attr_accessible :email, :handle, :subject, :body, :from_email, :status, :posted_dttm
end