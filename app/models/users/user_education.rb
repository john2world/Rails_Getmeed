class UserEducation
  include Mongoid::Document
  include LinkHelper
  include FeedItemsManager
  field :handle, type: String
  field :name, type: String
  field :degree, type: String
  field :major, type: String
  field :minor, type: String
  field :start_year, type: String
  field :end_year, type: String
  field :kudos_count, type: String


  attr_accessible :handle, :name, :degree, :major, :minor,
                  :start_year, :end_year, :kudos_count

  set_callback(:save, :after, if: (:name_changed? || :degree_changed? || :major_changed? || :minor_changed? ||
                        :start_year_changed? || :end_year_changed?)) do |document|
    SitemapPingerWorker.perform_async(get_user_profile_url(self.handle))
    save_user_state(self.handle, UserStateTypes::LAST_PROFILE_UPDATED)
  end
end