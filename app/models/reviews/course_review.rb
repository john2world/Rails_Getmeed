class CourseReview
  include FeedItemsManager
  include Mongoid::Document
  field :_id, type: String, default: -> {course_id}
  field :course_id, type: String
  field :course_code, type: String
  field :school_id, type: String
  field :prof_name, type: String
  field :rating, type: Float
  field :review, type: String
  field :reviewer_handle, type: String
  has_one :user_course, :class_name => 'UserCourse'
  field :create_dttm, type: Time, default: -> { Time.zone.now }

  attr_accessible :course_id, :course_code, :school_id, :prof_name, :rating, :review, :reviewer_handle

  set_callback(:save, :after) do |document|
    CreateFeedItemWorker.perform_async(handle, id.to_s, UserFeedTypes::USER_COURSE_REVIEW.downcase, nil)
  end
end