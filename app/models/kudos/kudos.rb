class Kudos
  include Mongoid::Document
  include LinkHelper
  field :handle, type: String
  field :giver_handle, type: String
  field :feed_id, type: String
  field :subject_id, type: String
  field :subject_type, type: String
  field :create_dttm, type: Date

  attr_accessible :handle, :create_dttm, :subject_id, :subject_type, :feed_id, :giver_handle
  set_callback(:save, :after) do |document|
  end

  def self.viewer_gave_kudos_to_feed? viewer, feed
    Kudos.where(:feed_id => feed.id, :giver_handle => viewer.handle).exists?
  end
end
