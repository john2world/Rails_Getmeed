class UserCourse
  include Mongoid::Document
  include FeedItemsManager
  include LinkHelper
  field :handle, type: String
  field :title, type: String
  field :description, type: String
  field :skills, type: Array
  field :semester, type: String
  field :year, type: String
  field :link, type: String
  field :kudos_count, type: String

  belongs_to :course_review
  has_many :course_project_reference
  has_many :course_project_reference_invitation

  attr_accessible :handle, :title, :description,
                  :skills, :semester, :year, :link,
                  :kudos_count

  set_callback(:save, :after, if: (:title_changed? || :description_changed? || :semester_changed? || :year_changed? ||
                        :link_changed?)) do |document|
    SitemapPingerWorker.perform_async(get_user_profile_url(self.handle))
    # CreateFeedItemWorker.perform_async(handle, id.to_s, UserFeedTypes::COURSEWORK.downcase, nil)
    save_user_state(self.handle, UserStateTypes::LAST_PROFILE_UPDATED)
  end

  def as_json(options={})
    options[:except] ||= [:create_dttm, :user_course]
    super(options)
  end

end