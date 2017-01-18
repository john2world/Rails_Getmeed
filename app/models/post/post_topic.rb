class PostTopic
  include Mongoid::Document
  field :_id, type: String, default: -> { post_topic_code }
  field :post_topic_code , type: String
  field :post_topic_name, type: String
  field :privacy, type: String, default: -> { 'everyone' }

  attr_accessible :_id, :post_topic_name, :post_topic_code, :privacy
end