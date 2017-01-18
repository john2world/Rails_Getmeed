class UserPublication
  include Mongoid::Document
  include FeedItemsManager
  include LinkHelper
  field :handle, type: String
  field :title, type: String
  field :description, type: String
  field :link, type: String
  field :year, type: String
  field :kudos_count, type: String


  attr_accessible :handle, :title, :description,
                  :link, :year, :kudos_count

  set_callback(:save, :after, if: (:title_changed? || :description_changed? || :link_changed? ||
                        :year_changed?)) do |document|
    SitemapPingerWorker.perform_async(get_user_profile_url(self.handle))
    CreateFeedItemWorker.perform_async(handle, id.to_s, UserFeedTypes::PUBLICATION.downcase, nil)
    save_user_state(self.handle, UserStateTypes::LAST_PROFILE_UPDATED)

  end
end