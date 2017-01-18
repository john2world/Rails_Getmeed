class UserWork
  include Mongoid::Document
  include LinkHelper
  include FeedItemsManager
  field :handle, type: String
  field :title, type: String
  field :company, type: String
  field :company_id, type: String
  field :description, type: String
  field :link, type: String
  field :skills, type: Array
  field :start_year, type: String
  field :start_month, type: String
  field :end_year, type: String
  field :end_month, type: String
  field :kudos_count, type: String

  has_many :work_reference, :class_name => 'WorkReference'

  attr_accessible :handle, :title, :company, :company_id, :description,
                  :link, :skills, :start_month, :start_year,
                  :end_month, :end_year, :kudos_count, :work_reference

  set_callback(:save, :after, if: (:title_changed? || :company_changed? || :company_id.changed? ||
                        :description_changed? || :link_changed? || :start_year_changed? || :start_month_changed? ||
                        :end_year_changed? || :end_month_changed?)) do |document|
    SitemapPingerWorker.perform_async(get_user_profile_url(self.handle))
    CreateFeedItemWorker.perform_async(handle, id.to_s, UserFeedTypes::USERWORK.downcase, nil)
    save_user_state(self.handle, UserStateTypes::LAST_PROFILE_UPDATED)
  end

end